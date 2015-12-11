module Kapa::PublicationBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
  end
end
