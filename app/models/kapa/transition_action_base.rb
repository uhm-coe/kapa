module Kapa::TransitionActionBase
  extend ActiveSupport::Concern

  included do
    self.inheritance_column = nil
    belongs_to :transition_point
    validates_presence_of :transition_point_id, :action, :action_date
    before_save :copy_type
    # after_save :update_curriculum # TODO: Uncomment after changing its implementation
  end

  #This type field needs to be exist in this model due to query performance
  def copy_type
    self.type = self.transition_point.type
  end

  def action_desc
    Kapa::Property.lookup_description("#{self.transition_point.type}_action", action)
  end

  def admissible?
    Kapa::Property.lookup_category("#{self.transition_point.type}_action", self.action) == "admissible"
  end
end
