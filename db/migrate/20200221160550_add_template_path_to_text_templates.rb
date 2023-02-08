class AddTemplatePathToTextTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column "text_templates", "template_path", :string
  end
end
