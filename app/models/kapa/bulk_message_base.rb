module Kapa::BulkMessageBase
  extend ActiveSupport::Concern

  included do
    has_many :messages
  end
end
