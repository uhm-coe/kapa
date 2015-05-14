module Kapa
  class Engine < Rails::Engine

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        app.config.paths["db/migrate"] += config.paths["db/migrate"].expanded
      end
    end

    initializer "kapa.assets.precompile" do |app|
      app.config.assets.precompile += %w(kapa.css kapa.js reports.js reports.css *.icon *.png)
    end

    config.generators do |g|
      g.assets false
      g.helper false
    end

  end
end

require 'rails'
require 'rails-secrets'
require 'authlogic'
require 'paperclip'
require 'fastercsv'
require 'mysql2'
require 'net-ldap'
require 'rails-csv-fixtures'
require 'sequel'
require 'jquery-rails'
require 'uglifier'
require 'libv8'
#require 'twitter-bootstrap-rails'
#require 'therubyracer'
require 'less-rails'
require 'will_paginate'
require 'will_paginate-bootstrap'
require 'bootstrap-datepicker-rails'
require 'bootstrap-multiselect-rails'
