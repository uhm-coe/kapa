class RenameAssessmentScores < ActiveRecord::Migration
  def change
    change_table :assessment_scores, :bulk => true do |t|
      t.integer :form_id, :null => false
      t.rename :assessment_criterion_id, :form_field_id
      t.rename :rating, :value
      t.remove :rated_by, :string
      t.remove  :assessment_scorable_type, :string
      t.remove  :assessment_scorable_id, :string
    end
    rename_table :assessment_scores, :form_details
  end
end
