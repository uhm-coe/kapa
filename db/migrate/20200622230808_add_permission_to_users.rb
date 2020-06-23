class AddPermissionToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column "users", "role", :text
    add_column "users", "permission", :text
  end
end
