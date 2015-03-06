class CreateDatasets < ActiveRecord::Migration
  def change
    create_table :datasets do |t|
      t.string :type
      t.string :name
      t.integer :data_source
      t.string :url
      t.text :query
      t.string :attr
      t.integer :record_count
      t.datetime :loaded_at
      t.timestamps
    end
  end
end
