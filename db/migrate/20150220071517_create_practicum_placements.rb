class CreatePracticumPlacements < ActiveRecord::Migration
  def change
    create_table "practicum_placements", :force => true do |t|
      t.integer  "person_id"
      t.integer  "term_id"
      t.integer  "curriculum_id"
      t.integer  "practicum_site_id"
      t.integer  "mentor_person_id"
      t.integer  "fee"
      t.text     "note"
      t.string   "category"
      t.string   "status"
      t.string   "dept"
      t.integer  "user_primary_id"
      t.integer  "user_secondary_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "yml"
      t.text     "xml"
    end

    add_index "practicum_placements", ["person_id"]
    add_index "practicum_placements", ["term_id"]
    add_index "practicum_placements", ["curriculum_id"]
    add_index "practicum_placements", ["practicum_site_id"]
    add_index "practicum_placements", ["mentor_person_id"]
    add_index "practicum_placements", ["user_primary_id"]
    add_index "practicum_placements", ["user_secondary_id"]
  end
end
