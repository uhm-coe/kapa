module Kapa
  class Engine < Rails::Engine

    initializer "kapa.assets.precompile" do |app|
      app.config.assets.precompile += %w(kapa.css kapa.js)
    end

  end
end




#TODO: loaded_specs['kapa'] returns nil when it is running on test/dummy
#Gem.loaded_specs['kapa'].runtime_dependencies.each do |d|
# require d.name
#end
