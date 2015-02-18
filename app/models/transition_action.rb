class TransitionAction < KapaBaseModel
  self.inheritance_column = nil
  belongs_to :transition_point
  validates_presence_of :action, :action_date
  before_save :copy_type
  # after_save :update_curriculum # TODO: Uncomment after changing its implementation

  #person must be verified before admitted.
  def validate
    if admissible? and not self.transition_point.person.verified?
      errors.add_to_base("Please the verify ID Number before actioning.")
    end
  end

  # TODO: Change its implementation
  # def update_curriculum
  #   logger.debug "-----#{ApplicationProperty.lookup_category(:transition_point, self.transition_point.type)} : #{ApplicationProperty.lookup_category("#{self.transition_point.type}_action", self.action)}"
  #   logger.debug "-----#{entrance?} : #{admissible?}"
  #   if entrance?
  #     # TODO: curriculums table does not have a term_id
  #     self.transition_point.curriculum.update_attributes(:academic_period => self.transition_point.academic_period, :active => admissible? ? 1 : 0)
  #   end
  # end

  #This type field needs to be exist in this model due to query performance
  def copy_type
     self.type = self.transition_point.type
  end

  def action_desc
    return ApplicationProperty.lookup_description("#{self.type}_action", action)
  end

  def admissible?
    ApplicationProperty.lookup_category("#{self.transition_point.type}_action", self.action) == "admissible"
  end
end
