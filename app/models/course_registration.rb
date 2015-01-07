class CourseRegistration < ApplicationModel
  belongs_to :person
  belongs_to :course
  has_many :assessment_scores, :as => :assessment_scorable
  
  def academic_period_desc
    self.course.academic_period_desc
  end

  def subject
    self.course.subject
  end
end
