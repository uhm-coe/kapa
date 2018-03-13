namespace :kapa do
  namespace :admin do

    desc 'Reapply user roles.'
    task :reset_role => :environment do

      Kapa::User.where(:status => "30").each do |user|
        permission = user.deserialize(:permission, :as => OpenStruct)
        puts "user: #{user.uid}, role: #{permission.role}"
        if permission.role and Rails.configuration.roles.keys.include?(permission.role)
          user.apply_role(permission.role)
          user.save!
        end
      end
    end

  end
end