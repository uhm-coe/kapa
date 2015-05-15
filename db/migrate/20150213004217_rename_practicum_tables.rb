class RenamePracticumTables < ActiveRecord::Migration

def change
    rename_table("practicum_profiles", "practicum_profiles_old")
    rename_table("practicum_placements", "practicum_placements_old")
    rename_table("practicum_assignments", "practicum_assignments_old")
    rename_table("practicum_schools", "practicum_schools_old")
  end

end
