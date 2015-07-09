module Kapa::CourseOfferBase
  extend ActiveSupport::Concern

  included do
    belongs_to :term
    has_many :course_registrations, -> {includes(:person, :assessment_scores).where("course_registrations.status like 'R%'").order("persons.last_name, persons.first_name")}
    validates_presence_of :term_id
  end # included

  def assessment_rubrics
    rubrics = Kapa::AssessmentRubric.eager_load(:assessment_criterions)
    rubrics = rubrics.where(["? between (select code from terms where id = assessment_rubrics.start_term_id) and (select code from terms where id = assessment_rubrics.end_term_id)", Kapa::Term.find(self.term_id).code])
    rubrics = rubrics.column_contains("assessment_rubrics.course" => "#{self.subject}#{self.number}").order("assessment_rubrics.title, assessment_criterions.criterion")
    if rubrics.blank?
      return [Kapa::AssessmentRubric.new(:title => "Not Defined")]
    else
      return rubrics
    end
  end

  def name
    return "#{subject}#{number}-#{section}"
  end

  def term_desc
    return Kapa::Term.find(term_id).description if term_id.present?
  end

  def table_for(assessment_rubric)
    table = ActiveSupport::OrderedHash.new
    self.course_registrations.each do |r|
      table.update Kapa::AssessmentScore.table_for(assessment_rubric, "CourseRegistration", r.id)
    end
    return table
  end

  def progress
    number_of_fields_total = 0
    number_of_fields_filled = 0
    self.assessment_rubrics.each do |ar|
      table = table_for(ar)
      number_of_fields_total += table.size
      number_of_fields_filled += table.values.delete_if { |r| r.blank? }.size
    end

    if number_of_fields_total == 0
      return 0
    else
      return number_of_fields_filled.to_f / number_of_fields_total.to_f * 100.to_f
    end
  end

  module ClassMethods
    def search(filter, options = {})
      course_offers = Kapa::CourseOff.eager_loades([:course_registrations => :assessment_scores]).where("course_offers.status" => "A")
      course_offers = course_offers.where("course_offers.term_id" => filter.term_id) if filter.term_id.present?
      course_offers = course_offers.where("course_offers.subject" => filter.subject) if filter.subject.present?
      course_offers = course_offers.where("course_offers.subject || course_offers.number || '-' || course_offers.section like ?", "%#{filter.name}%") if filter.name.present?

      case filter.user.access_scope
        when 3
          # Do nothing
        when 2
          # This may not be correct:
          course_offers = course_offers.where("concat(course_offers.subject, course_offers.number) in (?)", :course_offer, :depts => filter.user.depts) unless filter.user.manage? :course_offer
        # TODO: Implement the following condition using the where clause
        # f.append_property_condition "concat(course_offers.subject, course_offers.number) in (?)", :course_offer, :depts => @current_user.depts unless @current_user.manage? :course_offer
        when 1
          # TODO: Not implemented yet
        else
          course_offers = course_offers.where("1 = 2")
      end
      return course_offers
    end

    #TODO: Move complex query into reports module
    def to_csv(filter, options = {})
      sql = "SELECT
                courses.*,
                assessment_score_results.*,
                (select count(*) from course_registrations where status like 'R%' and course_id = courses.id) as registered
                FROM
                courses
                LEFT OUTER JOIN (
                  SELECT
                  course_registrations.course_id,
                  assessment_rubrics.title as assessment,
                  assessment_criterions.criterion,
                  assessment_criterions.criterion_desc,
                  sum(if(assessment_scores.rating = '2', 1, 0)) as target,
                  sum(if(assessment_scores.rating = '1', 1, 0)) as acceptable,
                  sum(if(assessment_scores.rating = '0', 1, 0)) as unacceptable,
                  sum(if(assessment_scores.rating = 'N', 1, 0)) as na
                  FROM assessment_scores
                  INNER JOIN course_registrations on assessment_scores.assessment_scorable_type = 'CourseRegistration' and assessment_scores.assessment_scorable_id = course_registrations.id
                  INNER JOIN assessment_criterions on assessment_scores.assessment_criterion_id = assessment_criterions.id
                  INNER JOIN assessment_rubrics on assessment_criterions.assessment_rubric_id = assessment_rubrics.id
                  WHERE 1=1
                  and course_registrations.status like 'R%'
                  and assessment_scores.rating not in ('')
                  GROUP BY
                  course_registrations.course_id,
                  assessment_rubrics.title,
                  assessment_criterions.criterion,
                  assessment_criterions.criterion_desc
                ) as assessment_score_results
                ON courses.id = assessment_score_results.course_id
                INNER JOIN terms ON terms.id = courses.term_id
              WHERE courses.status = 'A'
                AND courses.term_id = ?
              ORDER BY terms.sequence, subject, number, section, crn"

      courses = Kapa::CourseOffer.find_by_sql([sql, filter.term_id])
      CSV.generate do |csv|
        csv << self.csv_columns
        courses.each do |c|
          csv << self.csv_row(c)
        end
      end
    end

    def csv_columns
      [:term_id,
       :term_desc,
       :subject,
       :number,
       :section,
       :crn,
       :title,
       :instructor,
       :assessment,
       :criterion,
       :criterion_desc,
       :target,
       :acceptable,
       :unacceptable,
       :na,
       :registered]
    end

    def csv_row(c)
      [c.term_id,
       c.term_desc,
       c.subject,
       c.number,
       c.section,
       c.crn,
       c.title,
       c.instructor,
       c.assessment,
       c.criterion,
       c.criterion_desc,
       c.target,
       c.acceptable,
       c.unacceptable,
       c.na,
       c.registered]
    end
  end
end
