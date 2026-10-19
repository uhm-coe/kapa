class RenameTextTemplatesToContents < ActiveRecord::Migration[8.1]
  # Kapa::TextTemplate is now Kapa::Content. The old contents table (page/region/html, never used)
  # is dropped so the name can be reused.
  def up
    drop_table :contents
    rename_table :text_templates, :contents
    rename_column :texts, :text_template_id, :content_id
    execute "UPDATE contents SET template_path = '/kapa/contents/default' WHERE template_path = '/kapa/text_templates/default'"
    execute "UPDATE form_template_fields SET type = 'content_select' WHERE type = 'text_template_select'"
  end

  def down
    execute "UPDATE form_template_fields SET type = 'text_template_select' WHERE type = 'content_select'"
    execute "UPDATE contents SET template_path = '/kapa/text_templates/default' WHERE template_path = '/kapa/contents/default'"
    rename_column :texts, :content_id, :text_template_id
    rename_table :contents, :text_templates
    create_table :contents do |t|
      t.string :page, null: false
      t.string :region, null: false
      t.text :html
      t.timestamps
      t.text :yml
      t.json :json
    end
    add_index :contents, [:page, :region], unique: true
    add_index :contents, :page
  end
end
