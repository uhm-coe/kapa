class RenameAssessmentScores < ActiveRecord::Migration
  def change
    add_column :assessment_scores, :form_id, :integer, :null => false
    change_column_null :assessment_scores, :assessment_criterion_id, false
    rename_column :assessment_scores, :assessment_criterion_id, :form_field_id
    change_column :assessment_scores, :rating, :text
    rename_column :assessment_scores, :rating, :value
    remove_column :assessment_scores, :rated_by, :string
    remove_column  :assessment_scores, :assessment_scorable_type, :string
    remove_column  :assessment_scores, :assessment_scorable_id, :string
    remove_index  :assessment_scores, :scorable_and_criterion_id
    add_index :assessment_scores, [:form_id, :form_field_id], unique: true
    rename_table :assessment_scores, :form_details
  end
end
