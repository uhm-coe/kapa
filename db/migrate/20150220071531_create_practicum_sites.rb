class CreatePracticumSites < ActiveRecord::Migration
  def change
    create_table "practicum_sites", :force => true do |t|
      t.string   "code"
      t.string   "name"
      t.string   "name_short"
      t.string   "level_from"
      t.string   "level_to"
      t.string   "url"
      t.string   "district"
      t.string   "area"
      t.string   "area_group"
      t.string   "category"
      t.string   "status"
      t.text     "yml"
      t.text     "xml"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "practicum_sites", ["code"]
  end
end
