class AddPermissionToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column "users", "role", :string

    Kapa::User.where("status >= 30").each do |user|
      permission = user.deserialize(:permission, :as => OpenStruct)
      puts "user: #{user.uid}, role: #{permission.role}"
      if permission.role
        user.apply_role(permission.role)
        user.save!
      end
    end

  end

  def down
    remove_column "users", "role"
  end
end
