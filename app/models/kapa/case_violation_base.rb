module Kapa::CaseViolationBase
  extend ActiveSupport::Concern

  included do
    belongs_to :case
  end

  def policy_desc
    return Kapa::Property.lookup_description("policy", self.location)
  end
end
