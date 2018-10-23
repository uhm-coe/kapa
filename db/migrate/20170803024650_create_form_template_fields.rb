class CreateFormTemplateFields < ActiveRecord::Migration[4.2]
  def change
    create_table "form_template_fields", :force => true do |t|
      t.string "label"
      t.text "label_desc"
      t.text "label_html"
      t.string "category"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "form_template_id"
      t.text "yml"
      t.text "xml"
      t.string "type", default: "default", null: false
      t.string "type_option"
      t.boolean "active", default: true
      t.boolean "required"
      t.integer "sequence", default: 0
    end
  end
end
