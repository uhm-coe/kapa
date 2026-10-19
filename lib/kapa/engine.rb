Gem.loaded_specs['kapa'].runtime_dependencies.each {|d| require d.name} if Gem.loaded_specs['kapa']

module Kapa
  class Engine < Rails::Engine

    config.generators do |g|
      g.assets false
      g.stylesheets false
      g.helper false
      g.integration_tool false
      g.system_tests false
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
        ActiveRecord::Tasks::DatabaseTasks.migrations_paths = app.config.paths['db/migrate'].to_a
      end
    end

    initializer :kapa_mime_types do
      Mime::Type.register "application/octet-stream", :file unless Mime[:file]
    end

    initializer :kapa_date_formats do
      Time::DATE_FORMATS[:default]  = '%m/%d/%Y %I:%M %p'
      Time::DATE_FORMATS[:datetime] = '%m/%d/%Y %I:%M %p'
      Time::DATE_FORMATS[:time]     = '%I:%M:%S %p'
      Date::DATE_FORMATS[:date]     = '%m/%d/%Y'
      Date::DATE_FORMATS[:default]  = '%m/%d/%Y'
    end

    initializer :kapa_assets do |app|
      app.config.assets.precompile += %w[kapa_manifest.js]
    end

  end
end
