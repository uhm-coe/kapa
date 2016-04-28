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

  end
end