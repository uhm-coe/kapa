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
      table = ENV['table']
      timestamp = Time.now.strftime('-%Y%m%d-%H%M%S') unless ENV['timestamp'] == "no"
      directory = ENV['directory'] ||= "#{Rails.root}/db/backup"
      filename = "#{database}-#{table.nil? ? "backup" : table}#{timestamp}.sql"
      FileUtils.mkdir_p(directory)

      command = 'mysqldump'
      command += ' --add-drop-table'
      command += ' --default-character-set=utf8'
      command += " -u #{user}"
      command += " -h #{host}" unless host.blank?
      command += " -p#{password}" unless password.blank?
      command += " #{database}"
      command += " #{table}"  unless table.blank?
      command += " > '#{directory}/#{filename}'"
      sh command

    end

    desc 'Restores the database from a file in db/backup. Specify the buckup file name, i.e., file=kapa_p-dump-20110101-xxxxxx.sql'
    task :restore => :environment do

      db_config = Rails.configuration.database_configuration
      user = db_config[Rails.env]['username']
      password = db_config[Rails.env]['password']
      host = db_config[Rails.env]['host']
      database = db_config[Rails.env]['database']
      directory = ENV['directory'] ||= "#{Rails.root}/db/backup"
      filename = ENV['file']
      if filename.nil?
        filename = Dir.entries(directory).select {|f| f.include? "#{database}-backup"}.sort.last
        puts "File name was not specified.  Would you like to restore database from #{filename}? (y/N)"
        return if $stdin.gets.chomp.to_s.upcase != "Y"
      end
      command = 'mysql'
      command += " -u #{user}"
      command += " -h #{host}" unless host.blank?
      command += " -p#{password}" unless password.blank?
      command += " #{database}"
      command += " < '#{directory}/#{filename}'"
      sh command

    end
  end
end