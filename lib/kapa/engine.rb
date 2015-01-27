module Kapa
  class Engine < Rails::Engine
  end
end

#TODO: loaded_specs['kapa'] returns nil when it is running on test/dummy
#Gem.loaded_specs['kapa'].runtime_dependencies.each do |d|
# require d.name
#end
