module Kapa::PublicationBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    validates_presence_of :person_id
  end
end
