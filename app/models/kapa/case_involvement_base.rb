module Kapa::CaseInvolvementBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    belongs_to :case
    has_many :case_violations
  end

  def type_desc
    return Kapa::Property.lookup_description("case_involvement_type", self.type)
  end
end
