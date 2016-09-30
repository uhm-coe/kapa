class CreateTextTemplates < ActiveRecord::Migration

  def change
    create_table "text_templates", :force => true do |t|
      t.string  "title"
      t.text     "body"
      t.string   "type"
      t.string   "sequence"
      t.string   "category"
      t.boolean  "active", default: true
      t.string   "dept"
      t.text     "yml"
      t.text     "xml"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end