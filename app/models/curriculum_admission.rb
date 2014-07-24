class CurriculumAdmission < ActiveRecord::Base
  belongs_to :curriculum_event
  validates_numericality_of :cum_gpa, :allow_nil => true
  validates_numericality_of :major_cum_gpa, :allow_nil => true
  validates_numericality_of :interview_points, :allow_nil => true
  validates_numericality_of :field_exp_points, :allow_nil => true
  validates_numericality_of :praxis_points, :allow_nil => true
  
  def cum_gpa_points 
    gpa_points cum_gpa.to_f
  end
  
  def major_cum_gpa_points 
    gpa_points major_cum_gpa.to_f
  end
  
  def total_score
    field_exp_points.to_f + praxis_points.to_f + cum_gpa_points.to_f + major_cum_gpa_points.to_f + interview_points.to_f
  end
  
  private
  def gpa_points(gpa)
    points = 0
    if gpa >= 3.5 and gpa <= 4
      points = 25
    elsif gpa >= 3.0 and gpa < 3.5
      points = 20
    elsif gpa >= 2.75 and gpa <= 3.0
      points = 15
    elsif gpa >= 2.50 and gpa <= 2.75
      points = 10
    else
      points = 0
    end
  end
end
