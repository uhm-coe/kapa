module Kapa::CasePersonBase
  extend ActiveSupport::Concern

  included do
    self.table_name = :case_persons
    belongs_to :person
    belongs_to :case
  end

  def type_desc
    return Kapa::Property.lookup_description("#{self.case.type}_case_person_type", self.type)
  end
end
