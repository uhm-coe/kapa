module Kapa::PracticumPlacementBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    belongs_to :curriculum
    belongs_to :practicum_site
    belongs_to :mentor,
               :class_name => "Person",
               :foreign_key => "mentor_person_id"
    belongs_to :supervisor_primary,
               :class_name => "User",
               :foreign_key => "supervisor_primary_user_id"
    belongs_to :supervisor_secondary,
               :class_name => "User",
               :foreign_key => "supervisor_secondary_user_id"
    has_many :practicum_logs, -> {order("practicum_logs.log_date DESC")}
    has_many :user_assignments, :as => :assignable
    has_many :users, :through => :user_assignments


#    serialize :supervisor, Kapa::CsvSerializer

    validates_presence_of :person_id, :term_id
  end

  def term_desc
    "#{Kapa::Term.find(self.term_id).description}"
  end

  def type_desc
    return Kapa::Property.lookup_description(:placement_type, type)
  end

  def category_desc
    return Kapa::Property.lookup_description(:placement_category, category)
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      placements = Kapa::PracticumPlacement.eager_load({:users => :person}, :person, :practicum_site, :curriculum).order("people_practicum_placements.last_name, people_practicum_placements.first_name")
      placements = placements.where("practicum_placements.term_id = ?", filter.term_id) if filter.term_id.present?
      placements = placements.where("type" => filter.placement_type) if filter.placement_type.present?
      placements = placements.where("practicum_site_id" => filter.practicum_site_id) if filter.practicum_site_id.present?
      placements = placements.where("curriculums.program_id" => filter.program_id) if filter.program_id.present?
      placements = placements.where("curriculums.distribution" => filter.distribution) if filter.distribution.present?
      placements = placements.where("curriculums.major_primary" => filter.major) if filter.major.present?
      placements = placements.where("curriculums.cohort" => filter.cohort) if filter.cohort.present?
      placements = placements.assigned_scope(filter.user_id) if filter.user_id.present?

      case filter.user.access_scope(:kapa_practicum_placements)
        when 30
          # do nothing
        when 20
          placements = placements.depts_scope(filter.user.depts)
        when 10
          placements = placements.assigned_scope(filter.user.id)
        else
          placements = placements.none
      end

      return placements
    end

    def csv_format
      {:id_number => [:person, :id_number],
       :last_name => [:person, :last_name],
       :first_name => [:person, :first_name],
       :email => [:person, :email],
       :type => [:type],
       :term => [:term_desc],
       :mentor_person_id => [:mentor_person_id],
       :mentor_last_name => [:mentor, :last_name],
       :mentor_first_name => [:mentor, :first_name],
       :mentor_email => [:mentor, :email],
       :site_code => [:practicum_site, :code],
       :site_name => [:practicum_site, :name],
       # :total_mentors,
       # :content_area,
       # :supervisor
       :note => [:note]}
    end
  end
end
