module Kapa::PersonAssignmentBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    belongs_to :assignable, :polymorphic => true
  end
end
