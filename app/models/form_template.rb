class FormTemplate < ApplicationModel
  attr_accessor :yml_raw
  has_many :forms
  before_save :adjust_to_end_of_day

  def adjust_to_end_of_day
    self.due_at = to_end_of_day(self.due_at)
    self.deactivate_at = to_end_of_day(self.deactivate_at)
  end

  def academic_period_desc
    return ApplicationProperty.lookup_description("academic_period", academic_period)
  end
  
  def title
    title = "#{name}"
    title << "- #{academic_period_desc}" if not academic_period.blank?
    return title
  end
end
