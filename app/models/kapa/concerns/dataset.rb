module Kapa::Concerns::Dataset
  extend ActiveSupport::Concern

  included do
    self.inheritance_column = nil
  end # included

  def load
    remote_dataset = db_connection(:local).fetch(self.query)
    columns = remote_dataset.columns
    logger.debug columns.inspect

    local_connection = db_connection(:local)
    local_connection.create_table!(table_name) do
      columns.each do |c|
        String c
      end
    end

    remote_dataset.each do |r|
      local_connection[table_name].insert(r)
    end

    self.update_attributes(:attr => columns.join(","), :record_count => local_connection[table_name].count, :loaded_at => DateTime.now)
  end

  def to_json(filter)
    local_connection = db_connection(:local)
    dataset = local_connection[table_name]

    if filter.present?
      filter.each_pair do |key, value|
        # Don't filter the dataset if the value is empty
        #TODO: Check if we need to support LIKE statements
        dataset = dataset.where(key.to_sym => value) if value.present?
      end
    end
    logger.debug "Lading Sequel Dataset: #{dataset.sql}"

    json = {}
    json[:data_columns] = dataset.columns
    json[:data] = []
    dataset.all do |r|
      json[:data] << r.values_at(*json[:data_columns])
    end
    json[:pivot_rows] = []
    json[:pivot_columns] = []
    return json
  end

  def table_name
    "dataset_#{self.id.to_s.rjust(3, '0')}".to_sym
  end

  def db_connection(name)
    if (name.to_s == "local")
      Sequel.connect(Rails.configuration.database_configuration[Rails.env])
    else
      #Return extern data sources in config file
    end
  end
end
