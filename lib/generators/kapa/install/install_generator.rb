class Kapa::InstallGenerator < Rails::Generators::Base
  source_root Kapa::Engine.root

  desc "Installs required files for KAPA application"

  def install_initializers
    puts "Installing initializers..."
    copy_file("test/dummy/config/initializers/kapa.rb", "#{Rails.root}/config/initializers/kapa.rb")
    inject_into_file "#{Rails.root}/config/initializers/mime_types.rb", "Mime::Type.register \"application/octet-stream\", :file\n", :after => "# Add new mime types for use in respond_to blocks:\n"
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
