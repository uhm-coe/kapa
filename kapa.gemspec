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
  s.description = "KAPA provides consolidated information tools to organize office records including personal information, electronic documents, calendars, tasks, messaging/notifications, etc.... Tools are distributed as Rails Engine so that developers can easily customize designs and functions to fit your organizational needs."
  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', '~> 5.2.0'
  s.add_dependency 'authlogic', '~> 4.4.2'
  s.add_dependency 'american_date'
  s.add_dependency 'paperclip'
  s.add_dependency 'fastercsv'
  s.add_dependency 'net-ldap'
  s.add_dependency 'sequel'
  s.add_dependency 'hashids'
  s.add_dependency 'will_paginate'
  s.add_dependency 'will_paginate-bootstrap'
  s.add_dependency 'uglifier'
  s.add_dependency 'sass-rails'
  s.add_dependency 'bootstrap-sass'

end
