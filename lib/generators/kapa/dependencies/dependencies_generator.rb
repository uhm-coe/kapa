class Kapa::DependenciesGenerator < Rails::Generators::Base
  source_root Kapa::Engine.root

  desc "Add gem and yarn dependencies for KAPA application"
  
  def add_gem_dependencies
    puts "Adding gem dependencies..."
    gem 'rails-csv-fixtures', :git => 'https://github.com/uhm-coe/rails-csv-fixtures.git', :branch => "master"
    gem 'whenever', :require => false
  end

end
