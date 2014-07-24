class CurriculumAction < ApplicationModel
  belongs_to :curriculum_event
  validates_presence_of :action, :action_date

  #person must be verfied before admitted.
  def validate
    if self.action =~ /[1|2]/ and not self.curriculum_event.person.verified?
      errors.add_to_base("Please the verify ID Number before actioning.")
    end
  end

  def before_save
    self.context = self.curriculum_event.context if self.curriculum_event
  end

  def after_initialize
    self.action_date = Date.today if self.action_date.blank?
  end

  def after_save
    self.curriculum_event.save
  end

  def action_desc
    return ApplicationProperty.lookup_description("#{context}_action", action)
  end
  
end
