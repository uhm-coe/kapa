class CreateNotifications < ActiveRecord::Migration
  def change
    create_table "notifications", :force => true do |t|
      t.integer  "user_id"
      t.integer  "attachable_id", limit: 4
      t.string   "attachable_type", limit: 255
      t.string   "type"
      t.string   "title"
      t.text     "body"
      t.string   "sequence"
      t.boolean  "read", default: false
      t.boolean  "email_sent", default: false
      t.text     "yml"
      t.text     "xml"
      t.datetime "read_at"
      t.datetime "email_sent_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "notifications", ["user_id"]
  end
end
