module Kapa::UserAssignmentBase
  extend ActiveSupport::Concern

  included do
    belongs_to :user
    belongs_to :assignable, :polymorphic => true
  end

  def task_desc
    return Kapa::Property.lookup_description("task", task)
  end
end
