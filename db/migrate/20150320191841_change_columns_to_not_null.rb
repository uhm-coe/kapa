class ChangeColumnsToNotNull < ActiveRecord::Migration
  def up
    change_column :transition_points, :term_id, :integer, :default => 0, :null => false
    change_column :enrollments, :term_id, :integer, :default => 0, :null => false
    change_column :enrollments, :curriculum_id, :integer, :default => 0, :null => false
    change_column :transition_actions, :transition_point_id, :integer, :default => 0, :null => false
    change_column :course_offers, :term_id, :integer, :default => 0, :null => false
    change_column :practicum_placements, :person_id, :integer, :default => 0, :null => false
    change_column :practicum_placements, :curriculum_id, :integer, :default => 0, :null => false
    change_column :practicum_placements, :term_id, :integer, :default => 0, :null => false
    change_column :forms, :person_id, :integer, :default => 0, :null => false
    change_column :exams, :person_id, :integer, :default => 0, :null => false
    change_column :assessment_criterions, :assessment_rubric_id, :integer, :default => 0, :null => false
  end

  def down
  end
end
