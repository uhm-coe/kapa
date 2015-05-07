module Kapa::Concerns::Enrollment
  extend ActiveSupport::Concern

  included do
    belongs_to :curriculum
    belongs_to :term
    belongs_to :user_primary,
               :class_name => "User",
               :foreign_key => "user_primary_id"
    belongs_to :user_secondary,
               :class_name => "User",
               :foreign_key => "user_secondary_id"

    validates_presence_of :curriculum_id, :term_id
  end # included

  def practicum_assignments_select(assignment_type, index = nil)
    assignments = self.practicum_assignments.select { |a| a.assignment_type == assignment_type.to_s }
    if index
      return assignments[index]
    else
      return assignments
    end
  end

  def term_desc
    return Term.find(term_id).description
  end

  def assignment_desc(assignment_type)
    practicum_assignments_select(assignment_type).collect { |a| a.name }.join(", ")
  end

  module ClassMethods
    def search(filter, options = {})
      enrollments = Enrollment.includes([{:curriculum => :person}, {:curriculum => :program}])
      enrollments = enrollments.where("enrollments.term_id" => filter.term_id) if filter.term_id.present?
      if filter.program == "NA"
        enrollments = enrollments.where("programs.code is NULL")
      else
        enrollments = enrollments.where("programs.code" => filter.program) if filter.program.present?
      end
      enrollments = enrollments.where("curriculums.distribution" => filter.distribution) if filter.distribution.present?
      enrollments = enrollments.where("curriculums.major_primary" => filter.major) if filter.major.present?
      enrollments = enrollments.where("enrollments.category" => filter.category) if filter.category.present?

      case filter.user.access_scope
        when 3
          # do nothing
        when 2
          enrollments = enrollments.depts_scope(filter.user.depts)
        when 1
          enrollments = enrollments.assigned_scope(filter.user.id)
        else
          enrollments = enrollments.where("1 = 2") #Do not list any objects
      end
      return enrollments
    end

    def to_csv(filter, options = {})
      # TODO: For reference, remove later
      # enrollments = Enrollment.includes([
      #   {:practicum_profile =>
      #     [{:person => :contact}, {:curriculum => :program}]
      #   },
      #   {:user_primary => :person},
      #   {:user_secondary => :person},
      #   [:practicum_assignments =>
      #     [:practicum_site, {:person => :contact}, {:user_primary => :person}, {:user_secondary => :person}]
      #   ]
      # ])
      enrollments = self.search(filter).order("persons.last_name, persons.first_name")
      CSV.generate do |csv|
        csv << self.csv_columns
        enrollments.each do |c|
          csv << self.csv_row(c)
        end
      end
    end

    def csv_columns
      [:id_number,
       :last_name,
       :first_name,
       :email,
       :category,
       :sequence,
       :curriculum_id,
       # :cohort,
       # :term_admitted,
       :program_desc,
       :major_primary_desc,
       :major_secondary_desc,
       :distribution_desc,
       :location,
       :second_degree,
       # :bgc,
       # :bgc_date,
       # :insurance,
       # :insurance_effective_period,
       :note,
       # :group,
       # :off_sequence,
       # :ite401,
       # :ite402,
       # :ite404,
       # :ite405,
       :coordinator_1_uid,
       :coordinator_1_last_name,
       :coordinator_1_first_name,
       :coordinator_2_uid,
       :coordinator_2_last_name,
       :coordinator_2_first_name,
       :created_at,
       :updated_at,
       :term,
       :status,
       # :total_mentors,
       # TODO
       :cur_street,
       :cur_city,
       :cur_state,
       :cur_postal_code,
       :cur_phone]
    end

    def csv_row(c)
      row = []
      row += [c.rsend(:curriculum, :person, :id_number),
              c.rsend(:curriculum, :person, :last_name),
              c.rsend(:curriculum, :person, :first_name),
              c.rsend(:curriculum, :person, :email),
              c.rsend(:category),
              c.rsend(:sequence),
              c.rsend(:curriculum, :id),
              # c.rsend(:cohort),
              # c.rsend(:curriculum, :term_desc),
              c.rsend(:curriculum, :program, :description),
              c.rsend(:curriculum, :major_primary_desc),
              c.rsend(:curriculum, :major_secondary_desc),
              c.rsend(:curriculum, :distribution_desc),
              c.rsend(:curriculum, :location),
              c.rsend(:curriculum, :second_degree),
              # c.rsend(:practicum_profile, :bgc),
              # c.rsend(:practicum_profile, :bgc_date, [:strftime, "%m/%d/%Y"]),
              # c.rsend(:practicum_profile, :insurance),
              # c.rsend(:practicum_profile, :insurance_effective_period),
              c.rsend(:note).to_s.gsub(/\n/, ""),
              # c.rsend(:uid),
              # c.rsend(:practicum_profile, :ext, :off_sequence),
              # c.rsend(:practicum_profile, :ext, :ite401),
              # c.rsend(:practicum_profile, :ext, :ite402),
              # c.rsend(:practicum_profile, :ext, :ite404),
              # c.rsend(:practicum_profile, :ext, :ite405),
              c.rsend(:user_primary, :uid),
              c.rsend(:user_primary, :person, :last_name),
              c.rsend(:user_primary, :person, :first_name),
              c.rsend(:user_secondary, :uid),
              c.rsend(:user_secondary, :person, :last_name),
              c.rsend(:user_secondary, :person, :first_name),
              c.rsend(:created_at),
              c.rsend(:updated_at),
              c.rsend(:term_desc),
              c.rsend(:status)]
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

      row += [
          c.rsend(:curriculum, :person, :contact, :cur_street),
          c.rsend(:curriculum, :person, :contact, :cur_city),
          c.rsend(:curriculum, :person, :contact, :cur_state),
          c.rsend(:curriculum, :person, :contact, :cur_postal_code),
          c.rsend(:curriculum, :person, :contact, :cur_phone)
      ]

      return row
    end
  end
end
