class Kapa::DependenciesGenerator < Rails::Generators::Base
  source_root Kapa::Engine.root

  desc "Add gem and yarn dependencies for KAPA application"
  
  def add_gem_dependencies
    puts "Adding gem dependencies..."
    gem 'rails-csv-fixtures', :github => 'felixbuenemann/rails-csv-fixtures', :branch => 'rails-5.1-support'
    gem 'whenever', :require => false
  end

  def add_yarn_dependencies
    puts "Installing yarn dependencies..."
    run "yarn add jquery"
    run "yarn add rails-ujs"
    run "yarn add dragula"
    run "yarn add pivottable"
    run "yarn add moment"
    run "yarn add fullcalendar"
    run "yarn add bootstrap-multiselect"
    run "yarn add eonasdan-bootstrap-datetimepicker"
    run "yarn add summernote"
    run "yarn add codemirror"
    run "yarn add bootswatch@3.4.1 --tilde"
    run "yarn add bootstrap-3-typeahead"
  end
end
