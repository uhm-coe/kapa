class CourseRegistration < KapaBaseModel
  belongs_to :person
  belongs_to :course_offer
  has_many :assessment_scores, :as => :assessment_scorable

  def term_desc
    self.course_offer.term_desc
  end

  def subject
    self.course_offer.subject
  end
end
