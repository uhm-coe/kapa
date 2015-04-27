class UserSession < Authlogic::Session::Base
  include Kapa::Concerns::UserSession
end
