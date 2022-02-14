namespace :kapa do
  namespace :db do

    desc 'Create the database, run migrations, and initialize with the seed data .'
    task :setup => :environment do
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      Rake::Task["db:migrate"].invoke
      Rake::Task["db:seed"].invoke
    end

    desc 'List all fields in the specified model, i.e., rake db:attr model=kapa/person'
    task :attr => :environment do
      puts ENV['model'].classify.constantize.attribute_names.map(&:to_sym).sort.inspect
    end


    desc 'Backups the database to db/backup'
    task :backup => :environment do

      db_config = Rails.configuration.database_configuration
      user = db_config[Rails.env]['username']
      password = db_config[Rails.env]['password']
      host = db_config[Rails.env]['host']
      database = db_config[Rails.env]['database']
      if ENV['timestamp'] == "no"
        timestamp = ""
      elsif ENV['timestamp'].present?
        timestamp = Time.now.strftime("-#{ENV['timestamp']}") 
      else
        timestamp = Time.now.strftime('-%Y%m%d-%H%M%S') 
      end
      directory = ENV['directory'] ||= "#{Rails.root}/db/backup"
      filename = "#{database}-backup#{timestamp}.sql"
      FileUtils.mkdir_p(directory)

      command = 'mysqldump'
      command += ' --add-drop-table'
      command += ' --default-character-set=utf8'
      command += " --user=#{user}"
      command += " --host=#{host}" unless host.blank?
      command += " --password='#{password}'" unless password.blank?
      command += " #{database}"
      command += " > '#{directory}/#{filename}'"
      sh command, verbose: false do |ok, status|
        unless ok
          fail "Backup failed with status (#{status.exitstatus})"
        end
      end

    end

    desc 'Restores the database from a file in db/backup. Specify the full path to the buckup file, i.e., file=/srv/backup/kapa_p-dump-20110101-xxxxxx.sql'
    task :restore => :environment do

      if ENV['file'].nil?
        puts "Please provide the full path to the backup file, i.e., file=/srv/backup/kapa_p-dump-20110101-xxxxxx.sql"
        next
      end

      db_config = Rails.configuration.database_configuration
      user = db_config[Rails.env]['username']
      password = db_config[Rails.env]['password']
      host = db_config[Rails.env]['host']
      database = db_config[Rails.env]['database']
      directory = ENV['directory'] ||= "#{Rails.root}/db/backup"
      filename = ENV['file']
      command = 'mysql'
      command += " --user=#{user}"
      command += " --host=#{host}" unless host.blank?
      command += " --password='#{password}'" unless password.blank?
      command += " #{database}"
      command += " < '#{filename}'"
      sh command, verbose: false do |ok, status|
        unless ok
          fail "Restore failed with status (#{status.exitstatus})"
        end
      end

    end
  end
end