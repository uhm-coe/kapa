class Kapa::InstallGenerator < Rails::Generators::Base
  source_root Kapa::Engine.root

  desc "Installs required files for KAPA application"

  def install_initializers
    puts "Installing initializers..."

    copy_from_dummy("config/initializers/assets.rb")
    copy_from_dummy("config/initializers/attachments.rb")
    copy_from_dummy("config/initializers/cas.rb")
    copy_from_dummy("config/initializers/datasources.rb")
    copy_from_dummy("config/initializers/filter_parameter_logging.rb")
    copy_from_dummy("config/initializers/kapa.rb")
    copy_from_dummy("config/initializers/ldap.rb")
    copy_from_dummy("config/initializers/mailer.rb")
    copy_from_dummy("config/initializers/session_store.rb")
    copy_from_dummy("config/initializers/time_formats.rb")
    copy_from_dummy("config/initializers/users.rb")
    inject_into_file "#{Rails.root}/config/initializers/mime_types.rb", "Mime::Type.register \"application/octet-stream\", :file\n", :after => "# Add new mime types for use in respond_to blocks:\n"
  end
  
  def add_gem_dependencies
    puts "Adding gem dependencies..."
    gem 'rails-csv-fixtures', github: 'bfolkens/rails-csv-fixtures'
    gem 'activerecord-session_store'
    gem 'authlogic', '~> 3.4.0'
    gem 'american_date'
    gem 'paperclip', '~> 3.0'
    gem 'fastercsv'
    gem 'net-ldap', '~> 0.13.0'
    gem 'sequel'
    gem 'will_paginate', '~> 3.0'
    gem 'will_paginate-bootstrap'
    gem 'momentjs-rails', '>= 2.9.0'
    gem 'bootstrap-sass'
    gem 'bootstrap3-datetimepicker-rails', '~> 4.14.30'
    gem 'bootstrap-multiselect-rails'
    gem 'dragula-rails'
    gem 'hashids'
    gem 'summernote-rails'
    gem 'rails-assets-jquery', '1.12.4', source: 'https://rails-assets.org'
    gem 'rails-assets-pivottable', source: 'https://rails-assets.org'
  end

  def install_locale
    puts "Installing default locale..."
    copy_from_dummy("config/locales/en.yml")
  end

  def install_seeds
    puts "Installing database seeds..."
    copy_from_dummy("db/seeds.rb")
  end

  def install_fixtures
    puts "Installing fixtures..."
    directory("test/fixtures", "#{Rails.root}/test/fixtures")
  end

  private
  def copy_from_dummy(file_path)
    copy_file("test/dummy/#{file_path}", "#{Rails.root}/#{file_path}")
  end
end
