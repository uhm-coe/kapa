class RenameAssessmentCriterions < ActiveRecord::Migration
  def change
    change_table :assessment_criterions, :bulk => true do |t|
      t.rename :assessment_rubric_id, :form_template_id
      t.rename :criterion, :label
      t.rename :criterion_desc, :label_desc
      t.rename :criterion_html, :label_html
      t.rename :standard, :category
      t.boolean :required
      t.boolean :hide
    end
    rename_table :assessment_criterions, :form_fields
  end
end
