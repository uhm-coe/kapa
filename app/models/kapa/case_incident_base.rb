module Kapa::CaseIncidentBase
  extend ActiveSupport::Concern

  included do
    belongs_to :case
  end
end
