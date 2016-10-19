module Kapa::CourseRegistrationBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    belongs_to :course
    has_many :assessment_scores, :as => :assessment_scorable
  end

  def term_desc
    self.course.term_desc
  end

  def subject
    self.course.subject
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      course_registrations = Kapa::CourseRegistration.eager_load(:course => :term).where("courses.status" => "A").order("subject, number, section")
      course_registrations = course_registrations.where("courses.term_id" => filter.term_id) if filter.term_id.present?
      course_registrations = course_registrations.where("courses.subject" => filter.subject) if filter.subject.present?

      case filter.user.access_scope(:kapa_course_registrations)
        when 30
          # Do nothing
        when 20
#          course_registrations = course_registrations.depts_scope(filter.user.depts)
        when 10
          # TODO: Not implemented yet
        else
          course_registrations = course_registrations.where("1 = 2")
      end
      return course_registrations
    end
  end
end
