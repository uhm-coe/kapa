class Kapa::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc "Installs required files for KAPA application"

  def add_initializers
    install_file("#{Rails.root}/config/initializers/kapa.rb")
    install_file("#{Rails.root}/config/initializers/mime_types.rb")
  end

  def install_db
    puts "Installing database files..."
    install_file("#{Rails.root}/db/schema.rb")
    install_file("#{Rails.root}/db/seeds.rb")
  end

  def install_fixtures
    puts "Installing fixtures..."
    directory("#{Kapa::Engine.root}/test/fixtures", "#{Rails.root}/test/fixtures")
  end

  private
  def install_file(path)
    if File.exists?(path)
      puts "Skipping #{path} creation, as file already exists!"
    else
      puts "Installing a file (#{path})..."
      copy_file(File.basename(path), path)
    end
  end
end
