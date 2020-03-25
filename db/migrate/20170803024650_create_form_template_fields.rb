class CreateFormTemplateFields < ActiveRecord::Migration[4.2]
  def change
    create_table "form_template_fields", :force => true do |t|
      t.string "label"
      t.text "label_desc"
      t.text "hint"
      t.text "tip"
      t.string "category"
      t.integer "form_template_id"
      t.text "yml"
      t.json "json"
      t.string "type", null: false
      t.string "type_option"
      t.boolean "active", default: true
      t.boolean "required"
      t.integer "sequence", default: 0
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
