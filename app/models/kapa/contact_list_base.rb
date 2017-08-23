module Kapa::ContactListBase
  extend ActiveSupport::Concern

  included do
    has_many :contact_list_members
  end
end
