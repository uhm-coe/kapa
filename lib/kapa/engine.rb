Gem.loaded_specs['kapa'].runtime_dependencies.each {|d| require d.name} if Gem.loaded_specs['kapa']

module Kapa
  class Engine < Rails::Engine

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        #config.paths["db/migrate"].expanded.each do |expanded_path|
        #  app.config.paths["db/migrate"] << expanded_path
        #end
      end
    end
    config.autoload_paths << File.expand_path("../app", __FILE__)

    initializer "kapa.assets" do |app|
      app.config.assets.precompile += %w(kapa/kapa.css kapa/kapa.js kapa/reports.js kapa/reports.css *.icon *.png)
      app.config.assets.precompile << /.(?:svg|eot|woff|ttf)$/
    end

    config.generators do |g|
      g.assets false
      g.helper false
    end

  end
end
