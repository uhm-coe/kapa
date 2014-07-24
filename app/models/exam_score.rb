class ExamScore < ApplicationModel
  belongs_to :person
  belongs_to :exam

  def subject_desc
    return ApplicationProperty.lookup_description("exam_subject", subject)
  end

  def subscores
    if self.yml
      self.yml[:subscores]
    else
      []
    end  
  end
end
