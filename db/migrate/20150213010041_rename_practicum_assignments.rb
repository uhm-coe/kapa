class RenamePracticumAssignments < ActiveRecord::Migration

  def change
    @t = "practicum_placements"
    rename_table("practicum_assignments", @t)
    add_column(@t, :curriculum_id, :integer)
    add_index(@t, :curriculum_id)
  end

end
