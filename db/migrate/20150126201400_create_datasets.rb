class CreateDatasets < ActiveRecord::Migration
  def change
    create_table :datasets do |t|
      t.string :name
      t.string :description
      t.string :type
      t.string :category
      t.string :datasource
      t.text :query
      t.string :ldap_base
      t.string :ldap_filter
      t.text :ldap_attr
      t.integer :record_count
      t.datetime :loaded_at
      t.timestamps
      t.text :yml
      t.text :xml
    end
  end
end
