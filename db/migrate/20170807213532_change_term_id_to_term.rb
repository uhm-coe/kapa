class ChangeTermIdToTerm < ActiveRecord::Migration[4.2]
  def change
    change_column :forms, :term_id, :string
    rename_column :forms, :term_id, :term
  end
end
