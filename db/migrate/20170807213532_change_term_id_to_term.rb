class ChangeTermIdToTerm < ActiveRecord::Migration[4.2]
  def up
    change_column :forms, :term_id, :string
    rename_column :forms, :term_id, :term
  end

  def down
    rename_column :forms, :term, :term_id
    change_column :forms, :term_id, :integer
  end
end
