Gem.loaded_specs['kapa'].runtime_dependencies.each {|d| require d.name}

module Kapa
  class Engine < Rails::Engine

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        app.config.paths["db/migrate"] += config.paths["db/migrate"].expanded
      end
    end

    initializer "kapa.assets" do |app|
      app.config.assets.precompile += %w(kapa.css kapa.js reports.js reports.css *.icon *.png)
      app.config.assets.precompile << /.(?:svg|eot|woff|ttf)$/
    end

    config.generators do |g|
      g.assets false
      g.helper false
    end

  end
end
