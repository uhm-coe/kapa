module Kapa::UserSessionBase
  extend ActiveSupport::Concern

  included do
    # specify configuration here, such as:
    # logout_on_timeout true
    # ...many more options in the documentation
    verify_password_method :valid_credential?
    logout_on_timeout true
  end
end