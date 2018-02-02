class AddActiveOnAssessmentCriterions< ActiveRecord::Migration[4.2]
  def change
    change_table :assessment_criterions, :bulk => true do |t|
      t.boolean :active, :default => 1
    end
  end
end
