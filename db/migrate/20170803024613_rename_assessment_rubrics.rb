class RenameAssessmentRubrics < ActiveRecord::Migration
  def change
    change_table :assessment_rubrics, :bulk => true do |t|
      t.string :type
      t.string :template_path
    end
    rename_table :assessment_rubrics, :form_template
  end
end
