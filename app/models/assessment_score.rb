class AssessmentScore < ApplicationModel
  belongs_to :assessment_criterion
  belongs_to :assessment_scorable, :polymorphic => true
    
  def self.table_for(assessment_rubric, assessment_scorable_type, assessment_scorable_id) 
    table = ActiveSupport::OrderedHash.new
    #initialize table first
    for assessment_criterion in assessment_rubric.assessment_criterions
      index = "#{assessment_scorable_id}_#{assessment_criterion.id}"
      table[index] = ""
    end
    #then, fill in scores using ActiveRecord cache.  this is more efficient than filing everything one by one (save SQL execution)
    self.find(:all, :conditions => ["assessment_scorable_type = ? and assessment_scorable_id = ?", assessment_scorable_type, assessment_scorable_id]).each do |s|
      index = "#{s.assessment_scorable_id}_#{s.assessment_criterion_id}"
      table[index] = s.rating if table[index]
    end
    return table
  end

  #def self.assessment(assessment_rubric, assessment_scorable_type, assessment_scorable_id)
  #  self.find(:all, :conditions => ["assessment_scorable_type = ? and assessment_scorable_id = ?", assessment_scorable_type, assessment_scorable_id]).each do |s|
  #    index = "#{s.assessment_scorable_id}_#{s.assessment_criterion_id}"
  #    if table[index]
  #      table[index] = s.rating
  #      table[:academic_period] = s.academic_period
  #    end
  #  end
  #  return table
  #end
  #
  #def course?
  #  assessment_scorable_type == "AssessmentCourseRegistration"
  #end
  #
  #def self.find_assessment(assessment_rubric, assessment_scorable_type, assessment_scorable_id)
  #  sql = "SELECT
  #         if(assessment_scorable_type = 'CurriculumEvent', curriculum_events.program, concat(assessment_courses.subject, assessment_courses.number)) as rated_for,
  #         if(assessment_scorable_type = 'CurriculumEvent', assessments.academic_period_concat, assessment_courses.academic_period) as academic_period,
  #         assessments.*,
  #         assessment_rubrics.*
  #         FROM
  #         (SELECT assessment_scorable_type,
  #           assessment_scorable_id,
  #           assessment_criterions.assessment_rubric_id,
  #           group_concat(distinct rated_by) as rated_by,
  #           group_concat(distinct academic_period) as academic_period_concat,
  #           sum(if(assessment_scores.rating = '2', 1, 0)) as target,
  #           sum(if(assessment_scores.rating = '1', 1, 0)) as acceptable,
  #           sum(if(assessment_scores.rating = '0', 1, 0)) as unacceptable,
  #           sum(if(assessment_scores.rating = '2', 2, if(assessment_scores.rating = '1', 1, 0))) as total_score,
  #           count(assessment_criterions.id) * 2 as max_score
  #          FROM assessment_scores
  #          INNER JOIN assessment_criterions on assessment_scores.assessment_criterion_id = assessment_criterions.id
  #          WHERE 1=1
  #           and assessment_scores.assessment_scorable_type = ?
  #           and assessment_scores.assessment_scorable_id = ?
  #           and assessment_scores.rating not in ('', 'N')
  #          GROUP BY
  #           assessment_scorable_type,
  #           assessment_scorable_id,
  #           assessment_criterions.assessment_rubric_id) as assessments
  #         INNER JOIN assessment_rubrics ON assessments.assessment_rubric_id = assessment_rubrics.id
  #         LEFT OUTER JOIN assessment_course_registrations on assessments.assessment_scorable_type = 'AssessmentCourseRegistration' and assessments.assessment_scorable_id = assessment_course_registrations.id
  #         LEFT OUTER JOIN assessment_courses on assessment_course_registrations.assessment_course_id = assessment_courses.id
  #         LEFT OUTER JOIN curriculum_events on assessments.assessment_scorable_type = 'CurriculumEvent' and assessments.assessment_scorable_id = curriculum_events.id
  #         WHERE assessment_rubrics.id = ?
  #         limit 1"
  #  assessment = self.find_by_sql([sql, assessment_scorable_type, assessment_scorable_id, assessment_rubric.id]).first
  #  assessment ? assessment : OpenStruct.new
  #end
  #
  #def self.find_assessments(person_id)
  #  sql = "SELECT
  #         if(assessment_scorable_type = 'CurriculumEvent', curriculum_events.program, concat(assessment_courses.subject, assessment_courses.number)) as rated_for,
  #         if(assessment_scorable_type = 'CurriculumEvent', assessments.academic_period_concat, assessment_courses.academic_period) as academic_period,
  #         assessments.*,
  #         assessment_rubrics.*
  #         FROM
  #         (SELECT assessment_scorable_type,
  #           assessment_scorable_id,
  #           assessment_criterions.assessment_rubric_id,
  #           group_concat(distinct rated_by) as rated_by,
  #           group_concat(distinct academic_period) as academic_period_concat,
  #           sum(if(assessment_scores.rating = '2', 1, 0)) as target,
  #           sum(if(assessment_scores.rating = '1', 1, 0)) as acceptable,
  #           sum(if(assessment_scores.rating = '0', 1, 0)) as unacceptable,
  #           sum(if(assessment_scores.rating = '2', 2, if(assessment_scores.rating = '1', 1, 0))) as total_score,
  #           count(assessment_criterions.id) * 2 as max_score
  #          FROM assessment_scores
  #          INNER JOIN assessment_criterions on assessment_scores.assessment_criterion_id = assessment_criterions.id
  #          WHERE 1=1
  #           and assessment_scores.rating not in ('', 'N')
  #          GROUP BY
  #           assessment_scorable_type,
  #           assessment_scorable_id,
  #           assessment_criterions.assessment_rubric_id) as assessments
  #         INNER JOIN assessment_rubrics ON assessments.assessment_rubric_id = assessment_rubrics.id
  #         LEFT OUTER JOIN assessment_course_registrations on assessments.assessment_scorable_type = 'AssessmentCourseRegistration' and assessments.assessment_scorable_id = assessment_course_registrations.id
  #         LEFT OUTER JOIN assessment_courses on assessment_course_registrations.assessment_course_id = assessment_courses.id
  #         LEFT OUTER JOIN curriculum_events on assessments.assessment_scorable_type = 'CurriculumEvent' and assessments.assessment_scorable_id = curriculum_events.id
  #         WHERE assessment_course_registrations.person_id = ? or curriculum_events.person_id = ?
  #         ORDER BY 2 DESC"
  #  self.find_by_sql([sql, person_id, person_id])
  #end
end
