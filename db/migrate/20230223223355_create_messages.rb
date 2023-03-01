class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table "messages", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
      t.integer "messageable_id"
      t.string "messageable_type"
      t.string "type"
      t.text "to"
      t.text "from"
      t.text "cc"
      t.text "bcc"
      t.text "reply_to"
      t.string "subject"
      t.string "content_type", default: "text/html" 
      t.text "body"
      t.boolean "read", default: false
      t.boolean "email_sent", default: false
      t.datetime "read_at"
      t.datetime "sent_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "yml"
      t.text "xml"
      t.index ["messageable_type", "messageable_id"]
    end
  end
end
