class CourseRegistration < ApplicationModel
  belongs_to :person
  belongs_to :course
  has_many :assessment_scores, :as => :assessment_scorable

  def term_desc
    self.course.term_desc
  end

  def subject
    self.course.subject
  end
end
