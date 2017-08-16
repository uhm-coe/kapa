Gem.loaded_specs['kapa'].runtime_dependencies.each {|d| require d.name} if Gem.loaded_specs['kapa']

module Kapa
  class Engine < Rails::Engine

    config.autoload_paths << File.expand_path("#{Kapa::Engine.root}/app", __FILE__) if Rails.env.development?

    config.generators do |g|
      g.assets false
      g.helper false
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
      app.config.assets.precompile += %w(kapa/kapa.css kapa/kapa.js kapa/reports.js kapa/reports.css *.icon *.png kapa/document_editor.js)
      app.config.assets.precompile << /.(?:svg|eot|woff|ttf)$/
    end

  end
end
