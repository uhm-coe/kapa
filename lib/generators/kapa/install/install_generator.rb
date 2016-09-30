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
  
  def install_gemfiles
    inject_into_file "#{Rails.root}/Gemfile", "gem 'authlogic', '~> 3.4.0'\n", :after => /^(gem kapa)/
#    inject_into_file "#{Rails.root}/Gemfile", "gem 'american_date'\n"
    #inject_into_file "#{Rails.root}/Gemfile", "gem 'paperclip', '~> 3.0'\n"
    #inject_into_file "#{Rails.root}/Gemfile", "gem 'fastercsv'\n"
    #inject_into_file "#{Rails.root}/Gemfile", "gem 'mysql2', '~> 0.3.18'\n"
    #inject_into_file "#{Rails.root}/Gemfile", "gem 'net-ldap', '~> 0.13.0'\n"
    #inject_into_file "#{Rails.root}/Gemfile", "gem 'sequel'\n"
    #inject_into_file "#{Rails.root}/Gemfile", "gem 'will_paginate', '~> 3.0'\n"
    #inject_into_file "#{Rails.root}/Gemfile", "gem 'will_paginate-bootstrap'\n"
    #inject_into_file "#{Rails.root}/Gemfile", "gem 'uglifier'\n"
    #inject_into_file "#{Rails.root}/Gemfile", "gem 'jquery-rails'\n"
    #inject_into_file "#{Rails.root}/Gemfile", "gem 'therubyracer'\n"
    #inject_into_file "#{Rails.root}/Gemfile", "gem 'momentjs-rails', '>= 2.9.0'\n"
    #inject_into_file "#{Rails.root}/Gemfile", "gem 'sass-rails'\n"
    #inject_into_file "#{Rails.root}/Gemfile", "gem 'bootstrap-sass'\n"
    #inject_into_file "#{Rails.root}/Gemfile", "gem 'bootstrap3-datetimepicker-rails', '~> 4.14.30'\n"
    #inject_into_file "#{Rails.root}/Gemfile", "gem 'bootstrap-multiselect-rails'\n"
    #inject_into_file "#{Rails.root}/Gemfile", "gem 'dragula-rails'\n"
    #inject_into_file "#{Rails.root}/Gemfile", "gem 'rails-csv-fixtures'\n"
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
