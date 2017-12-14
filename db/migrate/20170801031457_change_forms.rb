class ChangeForms < ActiveRecord::Migration
  def change
    change_table :forms, :bulk => true do |t|
      t.integer :form_template_id
      t.string :submitted_by
    end
  end
end
