$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "kapa/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "kapa"
  s.version     = Kapa::VERSION
  s.authors     = ["Genta T."]
  s.email       = ["withhawaii@gmail.com"]
  s.homepage    = "https://coe.hawaii.edu"
  s.summary     = "Academic Records Applcation Engine"
  s.description = "KAPA provides consolidated information tools to support academic program administration. "

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.21"
end
