class AssessmentRubric < ApplicationModel
  attr_accessor :courses, :programs, :transition_points
  has_many :assessment_criterions, :order => "assessment_criterions.criterion", :dependent => :destroy
  validates_presence_of :title
  before_save :join_attributes

  def join_attributes
    self.program = @programs ? @programs.join(",") : "" if @programs
    self.course = @courses ? @courses.join(",") : "" if @courses
    self.transition_point = @transition_points ? @transition_points.join(",") : "" if @transition_points
  end

  def effective_term
    "#{Term.find(self.start_term_id).description} - #{Term.find(self.end_term_id).description}"
  end
end
