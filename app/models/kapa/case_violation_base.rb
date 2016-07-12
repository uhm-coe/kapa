module Kapa::CaseViolationBase
  extend ActiveSupport::Concern

  included do
    belongs_to :case_incident
    belongs_to :case_involvement
    validates :case_involvement_id, :presence => true
  end

  def policy_desc
    return Kapa::Property.lookup_description("policy", self.policy)
  end
end
