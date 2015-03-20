class ChangeColumnsToNotNull < ActiveRecord::Migration
  def up
    change_column :transition_points, :term_id, :integer, :default => 0, :null => false
    change_column :enrollments, :term_id, :integer, :default => 0, :null => false
    change_column :enrollments, :curriculum_id, :integer, :default => 0, :null => false
    change_column :transition_actions, :transition_point_id, :integer, :default => 0, :null => false
  end

  def down
  end
end
