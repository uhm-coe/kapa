module Kapa::CaseInvolvementBase
  extend ActiveSupport::Concern

  included do
    self.table_name = :case_involvements
    belongs_to :person
    belongs_to :case
  end

  def type_desc
    return Kapa::Property.lookup_description("case_involvement_type", self.type)
  end
end
