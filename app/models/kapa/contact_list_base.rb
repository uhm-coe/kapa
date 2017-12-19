module Kapa::ContactListBase
  extend ActiveSupport::Concern

  included do
    has_many :contact_list_members
    has_many :persons, :through => :contact_list_members
  end

  def members
    self.contact_list_members
  end
end
