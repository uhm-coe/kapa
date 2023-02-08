class CreateFormTemplates < ActiveRecord::Migration[4.2]
  def change
    create_table "form_templates", :force => true do |t|
      t.string "title"
      t.string "dept"
      t.string "type"
      t.string "template_path"
      t.text "note"
      t.boolean "attachment"
      t.text "yml"
      t.json "json"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
