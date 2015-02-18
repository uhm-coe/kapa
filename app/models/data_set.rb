class DataSet < KapaBaseModel
  attr_accessible :data_source_id, :loaded_at, :name, :query, :attr, :record_count, :type, :url

  self.inheritance_column = nil

  belongs_to :data_source

  def load
    remote_data_set = self.data_source.connection.fetch(self.query)
    columns = remote_data_set.columns
    logger.debug columns.inspect

    local_connection = DataSource.local_connection
    local_connection.create_table!(table_name) do
      columns.each do |c|
        String c
      end
    end

    remote_data_set.each do |r|
      local_connection[table_name].insert(r)
    end

    self.update_attributes(:record_count => local_connection[table_name].count, :loaded_at => DateTime.now)
  end

  def to_json
    local_connection = DataSource.local_connection
    data_set = local_connection[table_name]

    json = {}
    json[:data_columns] = data_set.columns
    json[:data] = []
    data_set.all do |r|
      json[:data] << r.values_at(*json[:data_columns])
    end
    json[:pivot_rows] = []
    json[:pivot_columns] = []
    return json
  end

  def table_name
    "data_set_#{self.id.to_s.rjust(3, '0')}".to_sym
  end
end
