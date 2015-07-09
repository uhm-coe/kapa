module Kapa::ExamScoreBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    belongs_to :exam
  end

  def subject_desc
    return Kapa::ApplicationProperty.lookup_description("exam_subject", subject)
  end

  def subscores
    if self.yml
      self.yml[:subscores]
    else
      []
    end
  end
end
