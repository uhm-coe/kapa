class CreateEnrollments < ActiveRecord::Migration

  def change
    create_table "enrollments", :force => true do |t|
      t.integer  "curriculum_id"
      t.integer  "term_id"
      t.string   "sequence"
      t.string   "category"
      t.string   "status"
      t.text     "note"
      t.string   "dept"
      t.integer  "user_primary_id"
      t.integer  "user_secondary_id"
      t.text     "yml"
      t.text     "xml"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "enrollments", ["curriculum_id"]
    add_index "enrollments", ["term_id"]
    add_index "enrollments", ["user_primary_id"]
    add_index "enrollments", ["user_secondary_id"]
  end
end
