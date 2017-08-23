module Kapa::ContactListMemberBase
  extend ActiveSupport::Concern

  included do
    belongs_to :contact_list
    belongs_to :person

    validates_presence_of :contact_list_id, :person_id
  end
end
