module Kapa::DatasetBase
  extend ActiveSupport::Concern

  included do
    attr_accessor :file
  end

  def datasource_type
    if self.datasource == "file"
      return "file"
    elsif self.datasource_config[:adapter] == "ldap"
      return "ldap"
    else
      return "database"
    end
  end

  def datasource_config(name = self.datasource)
    if name.to_s == "local"
      Rails.configuration.database_configuration[Rails.env]
    else
      Rails.application.secrets[name].deep_symbolize_keys
    end
  end

  def cache_id
    "dataset_#{self.id.to_s.rjust(3, '0')}".to_sym
  end

  def cache
    @cache = Sequel.connect(datasource_config(:local))[cache_id] if @cache.nil?
    return @cache
  end

  def build(attributes)
    db = Sequel.connect(datasource_config(:local))
    db.create_table!(cache_id) do
      attributes.each do |c|
        String c
      end
    end
  end

  def load
#    logger.debug "Datasource: #{datasource_config(self.datasource).inspect}"

    case self.datasource_type
      when "database"
        db = Sequel.connect(datasource_config(self.datasource))
        dataset = db.fetch(self.query)
        columns = dataset.columns
        logger.debug columns.inspect
        build(columns)
        dataset.each do |r|
          cache.insert(r)
        end

      when "ldap"
        ldap = Net::LDAP.new(datasource_config(self.datasource))
        search_options = {:base => self.ldap_base, :return_result => false}
        search_options[:filter] = self.ldap_filter if self.ldap_filter.present?
        if self.ldap_attr.blank?
          columns_hash = {}
          ldap.search(search_options) do |entry|
            entry.each do |attr, values|
              columns_hash[attr] = nil
            end
          end
          self.update_attributes(:ldap_attr => columns_hash.keys.join(","))
        end
        search_options[:attributes] = self.ldap_attr
        build(self.ldap_attr.split(/,\s*/))

        ldap.search(search_options) do |entry|
          row = {}
          entry.each do |attr, values|
            row[attr] = values.first.force_encoding("utf-8")
          end
          logger.debug "----inserting row:#{row.inspect}"
          cache.insert(row)
        end

      when "file"
        logger.debug "----importing:#{self.file.path}"
        CSV.foreach(self.file.path, :headers => true) do |row|
          logger.debug "----creating table:#{row.headers}"
          build(row.headers)
          break
        end
        CSV.foreach(self.file.path, :headers => true) do |row|
          logger.debug "----inserting row:#{row.inspect}"
          cache.insert(row.to_hash)
        end
    end

    self.update_attributes(:record_count => cache.count, :loaded_at => DateTime.now)
    self.serialize!(:columns, columns)
  end

  def to_json(filter)
    if filter.present?
      filter.each_pair do |key, value|
        # Don't filter the dataset if the value is empty
        #TODO: Check if we need to support LIKE statements
        cache = cache.where(key.to_sym => value) if value.present?
      end
    end
    logger.debug "Loading Sequel Dataset: #{cache.sql}"

    json = {}
    json[:data_columns] = cache.columns
    json[:data] = []
    cache.all do |r|
      json[:data] << r.values_at(*json[:data_columns])
    end
    json[:pivot_rows] = []
    json[:pivot_columns] = []
    return json
  end
end
