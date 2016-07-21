module Kapa::CaseCommunicationBase
  extend ActiveSupport::Concern

  included do
    belongs_to :case
    belongs_to :person
    belongs_to :user
    validates_presence_of :case_id, :person_id, :type, :contacted_at, :user_id
  end

  def type_desc
    Kapa::Property.lookup_description("communication_type", type)
  end
end
