class AddJsonFields < ActiveRecord::Migration[7.0]
  def change
    ActiveRecord::Base.connection.tables.delete_if {|t| %w[ar_internal_metadata schema_migrations].include?(t)}.each do |table| 
      say table
      remove_column(table, :xml) if column_exists?(table, :xml)
      add_column(table, :json, :json) if not column_exists?(table, :json)
    end
  end
end
