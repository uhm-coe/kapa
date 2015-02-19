class RenamePracticumPlacements < ActiveRecord::Migration

  def change
    @t = :enrollments
    rename_table("practicum_placements", @t)
    add_column(@t, :curriculum_id, :integer)
    add_index(@t, :curriculum_id)
  end

end
