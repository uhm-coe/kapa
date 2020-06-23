namespace :kapa do
  namespace :admin do

    desc 'Reapply user roles.'
    task :reset_role => :environment do

      Kapa::User.where(:status => "30").each do |user|
        puts "user: #{user.uid}, role: #{user.role}"
        if user.role.present? and Rails.configuration.roles.keys.include?(user.role)
          user.apply_role(user.role)
          user.save!
        end
      end
    end

  end
end