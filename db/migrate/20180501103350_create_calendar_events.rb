class CreateCalendarEvents < ActiveRecord::Migration[4.2]
  
  def change
    create_table "calendar_events", force: :cascade do |t|
      t.integer "person_id", limit: 4
      t.string "title", limit: 255
      t.string "dow", limit: 255
      t.boolean "repeat", default: false
      t.datetime "start"
      t.datetime "end"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "uuid", limit: 65535
      t.text "note", limit: 65535
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
    end

    add_index "calendar_events", ["person_id"]
  end
end