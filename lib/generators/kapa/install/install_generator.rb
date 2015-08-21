class Kapa::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc "Installs required files for KAPA application"

  def install_initializers
    puts "Installing initializers..."
    copy_file("kapa.rb", "#{Rails.root}/config/initializers/kapa.rb")
    inject_into_file "#{Rails.root}/config/initializers/mime_types.rb", "Mime::Type.register \"application/octet-stream\", :file\n", :after => "# Add new mime types for use in respond_to blocks:\n"
  end

  def install_seeds
    puts "Installing database seeds..."
    copy_file("#{Kapa::Engine.root}/db/seeds.rb", "#{Rails.root}/db/seeds.rb")
  end

  def install_fixtures
    puts "Installing fixtures..."
    directory("#{Kapa::Engine.root}/db/fixtures", "#{Rails.root}/db/fixtures")
  end
end
