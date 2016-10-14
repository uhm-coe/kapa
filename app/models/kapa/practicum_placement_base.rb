module Kapa::PracticumPlacementBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    belongs_to :curriculum
    belongs_to :practicum_site
    belongs_to :mentor,
               :class_name => "Person",
               :foreign_key => "mentor_person_id"
    has_many :practicum_logs, -> {order("practicum_logs.log_date DESC")}
    has_many :user_assignments, :as => :assignable
    has_many :users, :through => :user_assignments

#    serialize :supervisor, Kapa::CsvSerializer

    validates_presence_of :person_id, :start_term_id, :end_term_id
  end

  def start_term_desc
    "#{Kapa::Term.find(self.start_term_id).description}"
  end

  def end_term_desc
    "#{Kapa::Term.find(self.end_term_id).description}"
  end

  def effective_term_desc
    "#{Kapa::Term.find(self.start_term_id).description} - #{Kapa::Term.find(self.end_term_id).description}" if self.start_term_id.present? and self.end_term_id.present?
  end

  def category_desc
    return Kapa::Property.lookup_description(:placement_category, category)
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      placements = Kapa::PracticumPlacement.eager_load({:users => :person}, :person, :practicum_site, :curriculum).order("persons.last_name, persons.first_name")
      placements = placements.where("? between practicum_placements.start_term_id and practicum_placements.end_term_id", filter.term_id) if filter.term_id.present?
      placements = placements.where("type" => filter.placement_type) if filter.placement_type.present?
      placements = placements.where("practicum_site_id" => filter.practicum_site_id) if filter.practicum_site_id.present?
      placements = placements.where("curriculums.program_id" => filter.program_id) if filter.program_id.present?
      placements = placements.where("curriculums.distribution" => filter.distribution) if filter.distribution.present?
      placements = placements.where("curriculums.major_primary" => filter.major) if filter.major.present?
      placements = placements.where("curriculums.cohort" => filter.cohort) if filter.cohort.present?
      placements = placements.assigned_scope(filter.user_id) if filter.user_id.present?

      case filter.user.access_scope
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
       :first_name => [:person, :last_name],
       :email => [:person, :email],
       :type => [:type],
       :start_term => [:start_term_desc],
       :end_term => [:end_term_desc],
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
