class CreateDataSources < ActiveRecord::Migration
  def change
    create_table :data_sources do |t|
      t.string :type
      t.string :name
      t.string :url
      t.string :user
      t.string :password

      t.timestamps
    end
  end
end
