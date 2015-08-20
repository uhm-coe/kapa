# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require "rspec/rails"
require "capybara/rspec"
require "faker"
require "factory_girl_rails"

ENGINE_RAILS_ROOT = File.join(File.dirname(__FILE__), "../")

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include Capybara, :file_path => /\bspec\/requests\//
  #config.include Kapa::Engine.routes.url_helpers
  config.raise_errors_for_deprecations!
  config.include FactoryGirl::Syntax::Methods
  config.extend ControllerMacros, :type => :controller
end
