class RenameAssessmentScores < ActiveRecord::Migration
  def change
    change_table :assessment_scores, :bulk => true do |t|
      t.integer :form_id, :null => false
      t.rename :assessment_criterion_id, :form_template_field_id
      t.rename :rating, :field_data
      t.remove :rated_by
      t.remove  :assessment_scorable_type
      t.remove  :assessment_scorable_id
    end
    rename_table :assessment_scores, :form_details
  end
end
