module Kapa::CurriculumBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    belongs_to :program
    has_many :advising_sessions
    has_many :transition_points
    has_many :enrollments
    has_one :practicum_profile
    has_one :last_transition_point,
            -> { where("transition_points.id =
                                          (select t.id
                                           from transition_points t
                                           inner join terms tm on tm.id = t.term_id
                                           where t.curriculum_id = transition_points.curriculum_id
                                           order by tm.sequence desc
                                           limit 1)")},
            :class_name => "TransitionPoint"
    has_many :user_assignments, :as => :assignable
    has_many :users, :through => :user_assignments

    validates_presence_of :person_id, :program_id
    before_create :set_default_options
  end

  def set_default_options
    self.major_primary = self.program.major if self.major_primary.blank?
    self.distribution = self.program.distribution if self.distribution.blank?
    self.track = self.program.track if self.track.blank?
    self.location = self.program.location if self.location.blank?
  end

  def track_desc
    return Kapa::Property.lookup_description(:track, track)
  end

  def major_primary_desc
    return Kapa::Property.lookup_description(:major, major_primary)
  end

  def major_secondary_desc
    return Kapa::Property.lookup_description(:major, major_secondary)
  end

  def distribution_desc
    return Kapa::Property.lookup_description(:distribution, distribution)
  end

  def location_desc
    return Kapa::Property.lookup_description(:location, location)
  end

  def code
    texts = [program.degree]
    texts.push major_primary if major_primary.present?
    texts.push distribution if distribution.present?
    texts.push track if track.present?
    return texts.join("/")
  end

  def code_desc
    texts = [program.degree]
    texts.push major_primary_desc if major_primary_desc.present?
    texts.push distribution_desc if distribution_desc.present?
    texts.push track_desc if track_desc.present?
    return texts.join("/")
  end

  class_methods do
    def search(options ={})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      curriculums = Kapa::Curriculum.eager_load([:user_assignments, :transition_points, :program, :person]).order("persons.last_name, persons.first_name")
      #TODO filter admitted studnets .where("transition_actions.action" => ['1','2'])
      curriculums = curriculums.where("transition_points.term_id" => filter.term_id) if filter.term_id.present?
      curriculums = curriculums.where("transition_points.type" => filter.type.to_s) if filter.type.present?
      curriculums = curriculums.where("program_id" => filter.program_id) if filter.program_id.present?
      curriculums = curriculums.where("curriculums.distribution" => filter.distribution) if filter.distribution.present?
      curriculums = curriculums.where("curriculums.major_primary" => filter.major) if filter.major.present?
      curriculums = curriculums.where("curriculums.cohort" => filter.cohort) if filter.cohort.present?
      curriculums = curriculums.assigned_scope(filter.user_id) if filter.user_id.present?

      case filter.user.access_scope
        when 30
          # do nothing
        when 20
          curriculums = curriculums.depts_scope(filter.user.depts, filter.user.id)
        when 10
          curriculums = curriculums.assigned_scope(filter.user.id)
        else
          curriculums = curriculums.where("1 = 2") #Do not list any objects
      end
      return curriculums
    end

    def csv_formats
      {:id_number => [:person, :id_number],
       :last_name => [:person, :last_name],
       :first_name => [:person, :first_name],
       :cur_street => [:person, :cur_street],
       :cur_city => [:person, :cur_city],
       :cur_state => [:person, :cur_state],
       :cur_postal_code => [:person, :cur_postal_code],
       :cur_phone => [:person, :cur_phone],
       :email => [:person, :email],
       :curriculum_id => [:id],
       :program_desc => [:program, :description],
       :track_desc => [:track_desc],
       :major_primary_desc => [:major_primary_desc],
       :major_secondary_desc => [:major_secondary_desc],
       :distribution_desc => [:distribution_desc],
       :second_degree => [:second_degree]}
    end
  end
end
