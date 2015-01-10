class Form < ApplicationModel
  self.inheritance_column = nil
  belongs_to :person
  has_one :transition_point

  def academic_period_desc
    return ApplicationProperty.lookup_description(:academic_period, academic_period)
  end

  def type_desc
    return ApplicationProperty.lookup_description(:form, type)
  end

  def lock?
    lock == "Y"
  end

  def submit
    self.update_attributes(:submitted_at => DateTime.now, :lock => "Y")
  end

  def date
    self.submitted_at
  end

  def name
    if self.academic_period.blank?
      type_desc
    else
      "#{type_desc} (#{academic_period_desc})"
    end
  end
end
