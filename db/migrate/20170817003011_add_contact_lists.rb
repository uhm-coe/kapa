class AddContactLists < ActiveRecord::Migration
  def change
    create_table :contact_lists do |t|
      t.string :name
      t.text :description
      t.text :note
      t.string :dept
      t.text :yml
      t.text :xml
      t.timestamps
    end

    create_table :contact_list_members do |t|
      t.integer :contact_list_id
      t.integer :person_id
      t.text :note
      t.string :dept
      t.text :yml
      t.text :xml
      t.timestamps
    end
  end
end
