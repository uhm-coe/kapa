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
end
