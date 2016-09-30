class CreateTexts < ActiveRecord::Migration

  def change
    create_table "texts", :force => true do |t|
      t.integer  "person_id"
      t.integer "attachable_id", limit: 4
      t.string "attachable_type", limit: 255
      t.integer  "text_template_id"
      t.string  "title"
      t.text     "body"
      t.string   "sequence"
      t.string   "category"
      t.string   "status"
      t.string   "dept"
      t.text    "note"
      t.text     "yml"
      t.text     "xml"
      t.datetime "submitted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "texts", ["person_id"]
    add_index "texts", ["text_template_id"]
  end
end
