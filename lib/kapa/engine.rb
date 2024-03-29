Gem.loaded_specs['kapa'].runtime_dependencies.each {|d| require d.name} if Gem.loaded_specs['kapa']

module Kapa
  class Engine < Rails::Engine

    config.autoload_paths << File.expand_path("#{Kapa::Engine.root}/app", __FILE__) if Rails.env.development?

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

    initializer :kapa_assets do |app|
      app.config.assets.precompile += %w(kapa/*)
      app.config.assets.precompile << /.(?:svg|eot|woff|ttf|icon|ico|png)$/
    end

  end
end
