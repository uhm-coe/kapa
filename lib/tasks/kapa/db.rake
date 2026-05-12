require 'shellwords'
require 'tempfile'

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

      cnf = Tempfile.new(['.my', '.cnf'])
      begin
        cnf.write("[mysqldump]\npassword=#{password}\n") if password.present?
        cnf.close

        command  = 'mysqldump'
        command += " --defaults-extra-file=#{cnf.path.shellescape}" if password.present?
        command += ' --add-drop-table'
        command += ' --default-character-set=utf8'
        command += " --user=#{user.shellescape}"
        command += " --host=#{host.shellescape}" if host.present?
        command += " #{database.shellescape}"
        command += " > #{File.join(directory, filename).shellescape}"

        sh command, verbose: false do |ok, status|
          fail "Backup failed with status (#{status.exitstatus})" unless ok
        end
      ensure
        cnf.unlink
      end
    end

    desc 'Restores the database from a file in db/backup. Specify the full path to the buckup file, i.e., file=/srv/backup/kapa_p-dump-20110101-xxxxxx.sql'
    task :restore => :environment do

      if ENV['file'].nil?
        puts "Please provide the full path to the backup file, i.e., file=/srv/backup/myapp-backup-20110101-xxxxxx.sql"
        next
      end

      filename = ENV['file']
      unless File.exist?(filename)
        puts "File not found: #{filename}"
        next
      end

      db_config = Rails.configuration.database_configuration
      user = db_config[Rails.env]['username']
      password = db_config[Rails.env]['password']
      host = db_config[Rails.env]['host']
      database = db_config[Rails.env]['database']

      cnf = Tempfile.new(['.my', '.cnf'])
      begin
        cnf.write("[client]\npassword=#{password}\n") if password.present?
        cnf.close

        command  = 'mysql'
        command += " --defaults-extra-file=#{cnf.path.shellescape}" if password.present?
        command += " --user=#{user.shellescape}"
        command += " --host=#{host.shellescape}" if host.present?
        command += " #{database.shellescape}"
        command += " < #{filename.shellescape}"

        sh command, verbose: false do |ok, status|
          fail "Restore failed with status (#{status.exitstatus})" unless ok
        end
      ensure
        cnf.unlink
      end
    end
  end
end