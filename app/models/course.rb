class Course < ApplicationModel
  belongs_to :term
  has_many :course_registrations, :include => [:person, :assessment_scores], :conditions => "course_registrations.status like 'R%'", :order => "persons.last_name, persons.first_name"

  def assessment_rubrics
    logger.debug "----looking for rubrics"
    rubrics = AssessmentRubric.find(:all, :include => :assessment_criterions, :conditions => "find_in_set('#{self.subject}#{self.number}', assessment_rubrics.course) > 0 and '#{self.academic_period}' between assessment_rubrics.academic_period_start and assessment_rubrics.academic_period_end", :order => "assessment_rubrics.title, assessment_criterions.criterion")
    if rubrics.blank?
      return [AssessmentRubric.new(:title => "Not Defined")]
    else
      return rubrics
    end
  end

  def name
    return "#{subject}#{number}-#{section}"
  end

  def academic_period_desc
    return ApplicationProperty.lookup_description("academic_period", academic_period)
  end

  def table_for(assessment_rubric) 
    table = ActiveSupport::OrderedHash.new
    self.course_registrations.each do |r|
      table.update AssessmentScore.table_for(assessment_rubric, "CourseRegistration", r.id)
    end
    return table
  end  
  
#  def table_for(assessment_rubric) 
#    table = Hash.new
#    for course_registration in self.course_registrations
#      #initialize table first
#      for assessment_criterion in assessment_rubric.assessment_criterions
#        index = "#{course_registration.id}_#{assessment_criterion.id}"
#        table[index] = ""
#      end
#      #then, fill in scores using ActiveRecord cache.  this is more efficient than filing everything one by one (save SQL execution)
#      course_registration.assessment_scores.each do |s|
#        index = "#{course_registration.id}_#{s.assessment_criterion_id}"
#        table[index] = s.rating if table[index]
#      end
#    end
#    return table
#  end
    
  def progress
    number_of_fields_total = 0
    number_of_fields_filled = 0
    self.assessment_rubrics.each do |ar|
      table = table_for(ar)
      number_of_fields_total += table.size
      number_of_fields_filled += table.values.delete_if {|r| r.blank?}.size
    end

    if number_of_fields_total == 0
      return 0
    else
      return number_of_fields_filled.to_f / number_of_fields_total.to_f * 100.to_f
    end
  end
end
