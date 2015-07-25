module Kapa::UserAssignmentBase
  extend ActiveSupport::Concern

  included do
    belongs_to :user
    belongs_to :assignable, :polymorphic => true
  end
end
