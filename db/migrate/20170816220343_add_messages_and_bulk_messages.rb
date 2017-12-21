class AddMessagesAndBulkMessages < ActiveRecord::Migration
  def change
    create_table :messages, :force => true do |t|
      t.integer :person_id
      t.integer :message_template_id
      t.integer :bulk_message_id
      t.integer :attachable_id
      t.string :attachable_type
      t.string :name
      t.string :subject
      t.text :body
      t.datetime :delivered_at
      t.datetime :scheduled_at
      t.string :status, :default => "N"
      t.string :dept
      t.text :yml
      t.text :xml
      t.timestamps
    end

    add_index :messages, :person_id

    create_table :bulk_messages, :force => true do |t|
      t.integer :message_template_id
      t.string :name
      t.string :subject
      t.text :body
      t.datetime :delivered_at
      t.datetime :scheduled_at
      t.string :status
      t.text :note
      t.string :dept
      t.text :yml
      t.text :xml
      t.timestamps
    end
  end
end
