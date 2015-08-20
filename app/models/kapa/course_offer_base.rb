module Kapa::CourseOfferBase
  extend ActiveSupport::Concern

  included do
    belongs_to :term
    has_many :course_registrations, -> {includes(:person, :assessment_scores).where("course_registrations.status like 'R%'").order("persons.last_name, persons.first_name")}
    validates_presence_of :term_id
  end

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

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      course_offers = Kapa::CourseOffer.eager_load(:course_registrations).where("course_offers.status" => "A").order("subject, number, section")
      course_offers = course_offers.where("course_offers.term_id" => filter.term_id) if filter.term_id.present?
      course_offers = course_offers.where("course_offers.subject" => filter.subject) if filter.subject.present?
      course_offers = course_offers.where("concat(course_offers.subject, course_offers.number, '-', course_offers.section) like ?", "%#{filter.name}%") #if filter.name.present?
      case filter.user.access_scope
        when 3
          # Do nothing
        when 2
          course_offers = course_offers.depts_scope(filter.user.depts)
        when 1
          # TODO: Not implemented yet
        else
          course_offers = course_offers.where("1 = 2")
      end
      return course_offers
    end

    def csv_format
      {:term_id => [:term_id],
       :term_desc => [:term_desc],
       :subject => [:subject],
       :number => [:number],
       :section => [:section],
       :crn => [:crn],
       :title => [:title],
       :instructor => [:instructor],
       :status => [:status]}
    end
  end
end
