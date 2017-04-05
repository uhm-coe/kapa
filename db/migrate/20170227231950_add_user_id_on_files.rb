class AddUserIdOnFiles < ActiveRecord::Migration
  def change
    change_table :files, :bulk => true do |t|
      t.integer :user_id
    end
    Kapa::File.update_all("user_id = (select id from users where uid = uploaded_by)")
  end
end
