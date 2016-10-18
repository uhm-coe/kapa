class AddAuthlogicFieldsOnUsers < ActiveRecord::Migration

  def change
    change_table :users, :bulk => true do |t|
      t.datetime :last_request_at
      t.datetime :current_login_at
      t.datetime :last_login_at
      t.string  :current_login_ip
      t.string  :last_login_ip
      t.string :password_salt
    end
  end

end
