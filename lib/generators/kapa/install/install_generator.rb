class Kapa::InstallGenerator < Rails::Generators::Base
  source_root Kapa::Engine.root

  desc "Installs required files for KAPA application"

  def install_initializers
    puts "Installing initializers..."
    copy_file("test/dummy/config/initializers/kapa.rb", "#{Rails.root}/config/initializers/kapa.rb")
    copy_file("test/dummy/config/initializers/users.rb", "#{Rails.root}/config/initializers/users.rb")
    copy_file("test/dummy/config/initializers/attachments.rb", "#{Rails.root}/config/initializers/attachments.rb")
    copy_file("test/dummy/config/initializers/ldap.rb", "#{Rails.root}/config/initializers/ldap.rb")
    copy_file("test/dummy/config/initializers/datasources.rb", "#{Rails.root}/config/initializers/datasources.rb")
    copy_file("test/dummy/config/initializers/mailer.rb", "#{Rails.root}/config/initializers/mailer.rb")
    inject_into_file "#{Rails.root}/config/initializers/mime_types.rb", "Mime::Type.register \"application/octet-stream\", :file\n", :after => "# Add new mime types for use in respond_to blocks:\n"
  end
  
  def add_gem_dependencies
    gem 'rails', '~> 4.2.3'
    gem 'rails-csv-fixtures', :github => 'bfolkens/rails-csv-fixtures'
    gem 'rake'
    gem 'activerecord-session_store'
    gem 'authlogic', '~> 3.4.0'
    gem 'american_date'
    gem 'paperclip', '~> 3.0'
    gem 'fastercsv'
    gem 'mysql2', '~> 0.3.18'
    gem 'net-ldap', '~> 0.13.0'
    gem 'sequel'
    gem 'will_paginate', '~> 3.0'
    gem 'will_paginate-bootstrap'
    gem 'uglifier'
    gem 'jquery-rails'
    gem 'therubyracer'
    gem 'momentjs-rails', '>= 2.9.0'
    gem 'sass-rails'
    gem 'bootstrap-sass'
    gem 'bootstrap3-datetimepicker-rails', '~> 4.14.30'
    gem 'bootstrap-multiselect-rails'
    gem 'dragula-rails'
    gem 'hashids'
    gem 'summernote-rails'
  end

  def install_locale
    puts "Installing default locale..."
    copy_file("test/dummy/config/locales/en.yml", "#{Rails.root}/config/locales/en.yml")
  end

  def install_seeds
    puts "Installing database seeds..."
    copy_file("test/dummy/db/seeds.rb", "#{Rails.root}/db/seeds.rb")
  end

  def install_fixtures
    puts "Installing fixtures..."
    directory("test/fixtures", "#{Rails.root}/test/fixtures")
  end
end
