class CreateFormTemplateFields < ActiveRecord::Migration[4.2]
  def change
    create_table "form_template_fields", :force => true do |t|
      t.integer "form_template_id"
      t.string "name"
      t.string "type"
      t.text "label"
      t.text "hint"
      t.text "tip"
      t.boolean "active", default: true
      t.boolean "required"
      t.integer "sequence", default: 0
      t.text "yml"
      t.json "json"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
