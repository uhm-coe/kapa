class AddEmailFieldsToTextTemplates < ActiveRecord::Migration[8.1]
  # Text templates can be emails (type "email") as well as PDF letters. Email templates are looked
  # up by a stable code (titles can be renamed by staff) and have a Liquid subject.
  def change
    add_column :text_templates, :code, :string
    add_column :text_templates, :subject, :string
    add_index :text_templates, :code, :unique => true
  end
end
