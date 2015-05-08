module Kapa::Concerns::Dataset
  extend ActiveSupport::Concern

  included do
    self.inheritance_column = nil
  end # included

  def datasource_config(name)
    if name.to_s == "local"
      Rails.configuration.database_configuration[Rails.env]
    else
      Rails.application.secrets.datasources[name]
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

    case self.type
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

        if self.ldap_attr.blank?
          columns_hash = {}
          ldap.search(:base => self.ldap_base, :filter => self.ldap_filter, :return_result => false) do |entry|
            entry.each do |attr, values|
              columns_hash[attr] = nil
            end
          end
          self.update_attributes(:ldap_attr => columns_hash.keys.join(","))
        end
        columns = self.ldap_attr.split(/,[[:space:]]*/)
        build(columns)
        ldap.search(:base => self.ldap_base, :filter => self.ldap_filter, :attributes => self.ldap_attr, :return_result => false) do |entry|
          row = {}
          entry.each do |attr, values|
            row[attr] = values.first
          end
          logger.debug "----inserting row:#{row.inspect}"
          cache.insert(row)
        end

      when "file"
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
