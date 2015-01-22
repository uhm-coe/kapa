class Form < ApplicationBaseModel
  self.inheritance_column = nil
  belongs_to :person
  belongs_to :term
  has_one :transition_point

  def term_desc
    return Term.find(term_id).description
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
    if self.term_id.blank?
      type_desc
    else
      "#{type_desc} (#{term_desc})"
    end
  end
end
