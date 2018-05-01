module Kapa::CalendarEventBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
  end
end
