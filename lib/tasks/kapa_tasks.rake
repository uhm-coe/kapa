namespace :db do

  desc 'Create the database, run migrations, and initialize with the seed data .'
  task :install => :environment do
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:seed"].invoke
  end

end
