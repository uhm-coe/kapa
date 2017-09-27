class AddActiveOnAssessmentCriterions< ActiveRecord::Migration
  def change
    change_table :assessment_criterions, :bulk => true do |t|
      t.boolean :active, :default => 1
    end
  end
end
