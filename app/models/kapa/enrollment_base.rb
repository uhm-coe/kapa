module Kapa::EnrollmentBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    belongs_to :curriculum
    belongs_to :term
    has_many :user_assignments, :as => :assignable
    has_many :users, :through => :user_assignments
    validates_presence_of :curriculum_id, :term_id
  end

  def practicum_assignments_select(assignment_type, index = nil)
    assignments = self.practicum_assignments.select { |a| a.assignment_type == assignment_type.to_s }
    if index
      return assignments[index]
    else
      return assignments
    end
  end

  def term_desc
    return Kapa::Term.find(term_id).description
  end

  def category_desc
    return Kapa::Property.lookup_description(:enrollment_category, category)
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      enrollments = Kapa::Enrollment.eager_load([:person, {:curriculum => :program}], {:user_assignments => {:user => :person}}).order("persons.last_name, persons.first_name")
      enrollments = enrollments.where("enrollments.term_id" => filter.term_id) if filter.term_id.present?
      enrollments = enrollments.where("curriculums.program_id" => filter.program_id) if filter.program_id.present?
      enrollments = enrollments.where("curriculums.distribution" => filter.distribution) if filter.distribution.present?
      enrollments = enrollments.where("curriculums.major_primary" => filter.major) if filter.major.present?
      enrollments = enrollments.where("curriculums.cohort" => filter.cohort) if filter.cohort.present?
      enrollments = enrollments.where("enrollments.category" => filter.category) if filter.category.present?

      case filter.user.access_scope
        when 30
          # do nothing
        when 20
          enrollments = enrollments.depts_scope(filter.user.depts)
        when 10
          enrollments = enrollments.assigned_scope(filter.user.id)
        else
          enrollments = enrollments.where("1 = 2") #Do not list any objects
      end
      return enrollments
    end

    def csv_format
      {:id_number => [:person, :id_number],
       :last_name => [:person, :last_name],
       :first_name => [:person, :first_name],
       :email => [:person, :email],
       :email_alt => [:person, :email_alt],
       :term_desc => [:term_desc],
       :category => [:category],
       :sequence => [:sequence],
       :status => [:status],
       :curriculum_id => [:curriculum_id],
       :cohort => [:curriculum, :cohort],
       :program_desc => [:curriculum, :program, :description],
       :major_primary_desc => [:curriculum, :major_primary_desc],
       :major_secondary_desc => [:curriculum, :major_secondary_desc],
       :distribution_desc => [:curriculum, :distribution_desc],
       :location => [:curriculum, :location],
       :second_degree => [:curriculum, :second_degree],
       :note => [:note],
       :coordinator_1_uid => [:users, :first, :uid],
       :coordinator_1_last_name => [:users, :first, :person, :last_name],
       :coordinator_1_first_name => [:users, :first, :person, :first_name],
       :coordinator_2_uid => [:users, :second, :person, :uid],
       :coordinator_2_last_name => [:users, :second, :person, :last_name],
       :coordinator_2_first_name => [:users, :second, :person, :first_name],
       :created_at => [:created_at],
       :updated_at => [:updated_at],
       :cur_street => [:person, :cur_street],
       :cur_city => [:person, :cur_city],
       :cur_state => [:person, :cur_state],
       :cur_postal_code => [:person, :cur_postal_code],
       :cur_phone => [:person, :cur_phone]
      }
    end

    #def csv_row(c)

       # :bgc => [:practicum_profile, :bgc],
       # :bgc_date => [:practicum_profile, :bgc_date],
       # :insurance => [:practicum_profile, :insurance],
       # :insurance_effective_period => [:practicum_profile, :insurance_effective_period],
       # :note2 => [:practicum_profile, :note],
       # :group => [:cohort_group],
       # :off_sequence => [],
       # :ite401 => [],
       # :ite402 => [],
       # :ite404 => [],
       # :ite405 => [],
       # :total_mentors => [],

    #  row = []
      # c.rsend([:practicum_assignments_select, :mentor], :length)] # if @current_user.manage?

      # TODO
      # 3.times do |i|
      #   key = "a#{i + 1}"
      #   row += [
      #     ["#{key}_mentor_person_id", rsend(o, :practicum_assignments, [:at, i], :person_id)],
      #     ["#{key}_mentor_last_name", rsend(o, :practicum_assignments, [:at, i], :person, :last_name)],
      #     ["#{key}_mentor_first_name", rsend(o, :practicum_assignments, [:at, i], :person, :first_name)],
      #     ["#{key}_mentor_email", rsend(o, :practicum_assignments, [:at, i], :person, :contact, :email)],
      #     ["#{key}_site_code", rsend(o, :practicum_assignments, [:at, i], :practicum_site, :code)],
      #     ["#{key}_site_name", rsend(o, :practicum_assignments, [:at, i], :practicum_site, :name_short)],
      #     ["#{key}_content_area", rsend(o, :practicum_assignments, [:at, i], :content_area)],
      #     ["#{key}_payment", rsend(o, :practicum_assignments, [:at, i], :payment)],
      #     ["#{key}_supervisor_1_uid", rsend(o, :practicum_assignments, [:at, i], :user_primary, :uid)],
      #     ["#{key}_supervisor_1_last_name", rsend(o, :practicum_assignments, [:at, i], :user_primary, :person, :last_name)],
      #     ["#{key}_supervisor_1_first_name", rsend(o, :practicum_assignments, [:at, i], :user_primary, :person, :first_name)],
      #     ["#{key}_supervisor_2_uid", rsend(o, :practicum_assignments, [:at, i], :user_secondary, :uid)],
      #     ["#{key}_supervisor_2_last_name", rsend(o, :practicum_assignments, [:at, i], :user_secondary, :person, :last_name)],
      #     ["#{key}_supervisor_2_first_name", rsend(o, :practicum_assignments, [:at, i], :user_secondary, :person, :first_name)],
      #     ["#{key}_note", rsend(o, :practicum_assignments, [:at, i], :note)]
      #   ]
      # end

    #  row += [
    #      c.rsend(:curriculum, :person, :cur_street),
    #      c.rsend(:curriculum, :person, :cur_city),
    #      c.rsend(:curriculum, :person, :cur_state),
    #      c.rsend(:curriculum, :person, :cur_postal_code),
    #      c.rsend(:curriculum, :person, :cur_phone)
    #  ]
    #
    #  return row
    #end
  end
end
