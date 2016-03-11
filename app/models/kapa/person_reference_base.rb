module Kapa::PersonReferenceBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    belongs_to :referenceable, :polymorphic => true
  end
end
