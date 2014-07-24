class AssessmentCourseRegistration < ApplicationModel
  belongs_to :person
  belongs_to :assessment_course
  has_many :assessment_scores, :as => :assessment_scorable
  
  def academic_period_desc
    self.assessment_course.academic_period_desc
  end

  def subject
    self.assessment_course.subject
  end
end
