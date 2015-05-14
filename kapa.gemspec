$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "kapa/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "kapa"
  s.version     = Kapa::VERSION
  s.authors = ["College of Education, University of Hawaiʻi at Mānoa"]
  s.email       = ["withhawaii@gmail.com"]
  s.homepage    = "https://coe.hawaii.edu"
  s.summary     = "Academic Records Applcation Engine"
  s.description = "KAPA provides consolidated information tools to support academic program administration. "

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  gem 'rails', '3.2.21'
  gem 'rails-secrets'
  gem 'authlogic'
  gem 'paperclip', '~> 3.0'
  gem 'fastercsv'
  gem 'mysql2'
  gem 'net-ldap'
  gem 'rails-csv-fixtures'
  gem 'sequel'
  gem 'jquery-rails'
  gem 'uglifier'
  gem 'libv8', '~> 3.11.8'
#  gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git', :branch => 'bootstrap3'
  gem 'therubyracer'
  gem 'less-rails'
  gem 'will_paginate', '~> 3.0'
  gem 'will_paginate-bootstrap'
  gem 'bootstrap-datepicker-rails', '~> 1.3.1.1'
  gem 'bootstrap-multiselect-rails'
end
