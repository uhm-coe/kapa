class ChangeTermIdToTerm < ActiveRecord::Migration
  def change
    change_column :form_templates, :start_term_id, :string
    change_column :form_templates, :end_term_id, :string
    rename_column :form_templates, :start_term_id, :start_term
    rename_column :form_templates, :end_term_id, :end_term
    change_column :forms, :term_id, :string
    rename_column :forms, :term_id, :term
  end
end
