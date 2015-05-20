$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "kapa/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "kapa"
  s.version     = Kapa::VERSION
  s.authors = ["College of Education, University of Hawaii at Manoa"]
  s.email       = ["sishelp@hawaii.edu"]
  s.homepage    = "https://coe.hawaii.edu"
  s.summary     = "Academic Records Engine"
  s.description = "KAPA provides a framework to organize student academic records including advising, documents, courses, transition points, field placements, etc..."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', '4.2.1'
  s.add_dependency 'authlogic'
  s.add_dependency 'paperclip', '~> 3.0'
  s.add_dependency 'fastercsv'
  s.add_dependency 'mysql2'
  s.add_dependency 'net-ldap'
  s.add_dependency 'sequel'
  s.add_dependency 'will_paginate', '~> 3.0'
  s.add_dependency 'will_paginate-bootstrap'
  s.add_dependency 'uglifier'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'therubyracer'
  s.add_dependency 'less-rails'
  s.add_dependency 'twitter-bootstrap-rails'
  s.add_dependency 'bootstrap-datepicker-rails', '~> 1.3.1.1'
  s.add_dependency 'bootstrap-multiselect-rails'
#  s.add_dependency 'rails-csv-fixtures'
end
