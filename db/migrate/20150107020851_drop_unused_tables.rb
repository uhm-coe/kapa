class DropUnusedTables < ActiveRecord::Migration

  def up
    drop_table(:curriculum_actions)
    drop_table(:curriculum_admissions)
    drop_table(:curriculum_events)
    drop_table(:curriculum_graduations)
    drop_table(:form_templates)
    drop_table(:menus)
  end

  def down
  end

end
