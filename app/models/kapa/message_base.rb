module Kapa::MessageBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    belongs_to :bulk_message

    validates_presence_of :person_id
  end
end
