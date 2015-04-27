# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class Kapa::KapaBaseController < ActionController::Base
  include Kapa::Concerns::KapaBaseController
end
