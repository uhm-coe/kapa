require File.expand_path('../boot', __FILE__)
require 'ostruct'
require 'yaml'
app_config = YAML.load(File.read(File.expand_path('../app_config.yml', __FILE__)))
::AppConfig = OpenStruct.new(app_config)


require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Kapa
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Hawaii'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Asset pipeline can be disabled  by putting this line inside the application class.
    config.assets.enabled = true

    # add app/assets/fonts to the asset path
    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :ssn]
    
    # By default, Rails generates migrations that look like:
    # 20080717013526_your_migration_name.rb
    # The prefix is a generation timestamp (in UTC).
    # If you'd prefer to use numeric prefixes, you can turn timestamped migrations off by setting:
    config.active_record.timestamped_migrations = false

    # Specify which actions the application checks authkey.
    config.validate_authkey = %w(show update destroy)
  end
end

# Include external libraries
require 'net/http'
require "net/https"
require 'net/ldap'
require "digest/sha1"
require 'openssl'
require 'base64'
require 'csv'