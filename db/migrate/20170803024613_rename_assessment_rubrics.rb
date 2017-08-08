class RenameAssessmentRubrics < ActiveRecord::Migration
  def change
    change_table :assessment_rubrics, :bulk => true do |t|
      t.string :type
      t.string :template_path
      t.text :note
      t.boolean :attachment
      t.boolean :active, :default => 1
    end
    rename_table :assessment_rubrics, :form_templates
  end
end
