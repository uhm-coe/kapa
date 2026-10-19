namespace :kapa do
  namespace :contents do

    desc 'Replace all contents in the database with db/fixtures/contents.yml (force=yes in production)'
    task :load do
      # Checked before loading the app, so nothing connects to a production database without force=yes.
      if Rails.env.production? and ENV['force'] != "yes"
        abort "This replaces contents staff edited in production. Run with force=yes to continue."
      end
      Rake::Task[:environment].invoke
      ActiveRecord::FixtureSet.create_fixtures(Rails.root.join("db/fixtures"), "contents")
      puts "Loaded #{Kapa::Content.count} contents from db/fixtures/contents.yml."
    end

    desc 'Dump all contents in the database to db/fixtures/contents.yml, i.e., rake kapa:contents:dump file=tmp/contents.yml'
    task :dump => :environment do
      file = ENV['file'].present? ? ENV['file'] : Rails.root.join("db/fixtures/contents.yml")
      File.write(file, Kapa::Content.to_fixtures)
      puts "Wrote #{Kapa::Content.count} contents to #{file}."
    end

  end
end
