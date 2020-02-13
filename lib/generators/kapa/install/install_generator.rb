class Kapa::InstallGenerator < Rails::Generators::Base
  source_root Kapa::Engine.root

  desc "Installs required files for KAPA application"

  def install_initializers
    puts "Installing initializers..."

    copy_from_dummy("config/initializers/attachments.rb")
    copy_from_dummy("config/initializers/cas.rb")
    copy_from_dummy("config/initializers/datasources.rb")
    copy_from_dummy("config/initializers/filter_parameter_logging.rb")
    copy_from_dummy("config/initializers/kapa.rb")
    copy_from_dummy("config/initializers/ldap.rb")
    copy_from_dummy("config/initializers/mailer.rb")
    copy_from_dummy("config/initializers/time_formats.rb")
    copy_from_dummy("config/initializers/users.rb")
    inject_into_file "#{Rails.root}/config/initializers/mime_types.rb", "Mime::Type.register \"application/octet-stream\", :file\n", :after => "# Add new mime types for use in respond_to blocks:\n"
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

  def add_routes
    route "root :to => redirect('/kapa')"
  end

  def install_dependencies
    generate "kapa:dependencies"
  end

  private
  def copy_from_dummy(file_path)
    copy_file("test/dummy/#{file_path}", "#{Rails.root}/#{file_path}")
  end
end
