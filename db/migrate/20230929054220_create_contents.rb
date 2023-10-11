class CreateContents < ActiveRecord::Migration[5.2]
  def change
    create_table "contents", force: :cascade do |t|
      t.string   "page",       limit: 255,   null: false
      t.string   "region",     limit: 255,   null: false
      t.text     "html",       limit: 65535
      t.datetime "created_at",               null: false
      t.datetime "updated_at",               null: false
      t.text "yml"
      t.json "json"
    end
    add_index "contents", ["page", "region"], name: "index_contents_on_page_and_region", unique: true, using: :btree
    add_index "contents", ["page"], name: "index_contents_on_page", using: :btree
  end
end
