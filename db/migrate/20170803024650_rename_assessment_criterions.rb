class RenameAssessmentCriterions < ActiveRecord::Migration
  def change
    change_table :assessment_criterions, :bulk => true do |t|
      t.rename :assessment_rubric_id, :form_template_id
      t.rename :criterion, :field_label
      t.rename :criterion_desc, :field_desc
      t.rename :criterion_html, :field_html
      t.rename :standard, :field_category
      t.boolean :required
      t.boolean :hide
    end
    rename_table :assessment_criterions, :form_template_fields
  end
end
