module Kapa::CaseIncidentBase
  extend ActiveSupport::Concern

  included do
    belongs_to :case
    has_many :case_violations, :dependent => :destroy
  end

  def location_desc
    return Kapa::Property.lookup_description("case_location", self.location)
  end
end
