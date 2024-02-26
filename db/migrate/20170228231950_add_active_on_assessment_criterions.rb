class AddActiveOnAssessmentCriterions< ActiveRecord::Migration[5.2]
  def change
    change_table :assessment_criterions, :bulk => true do |t|
      t.boolean :active, :default => 1
    end
  end
end
