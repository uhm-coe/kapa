module Kapa
  class Engine < Rails::Engine
  end
end

Gem.loaded_specs['kapa'].dependencies.each do |d|
 require d.name
end
