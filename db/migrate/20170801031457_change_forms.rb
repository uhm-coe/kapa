class ChangeForms < ActiveRecord::Migration[4.2]
  def change
    change_table :forms, :bulk => true do |t|
      t.integer :form_template_id
      t.string :submitted_by
    end
  end
end
