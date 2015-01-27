class CreateDataSets < ActiveRecord::Migration
  def change
    create_table :data_sets do |t|
      t.string :type
      t.string :name
      t.integer :data_source_id
      t.string :url
      t.text :query
      t.string :attr
      t.integer :record_count
      t.datetime :loaded_at

      t.timestamps
    end
  end
end
