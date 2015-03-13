class Dataset < KapaBaseModel
  self.inheritance_column = nil

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
      filter.each do |f|
        # Don't filter the dataset if the value is empty
        dataset = dataset.where("#{f[0]} LIKE ?", "%#{f[1]}%") if f[1].present?
      end
    end

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

  private
  def db_connection(name)
    if (name.to_s == "local")
      Sequel.connect(Rails.configuration.database_configuration[Rails.env])
    else
      #Return extern data sources in config file
    end
  end
end
