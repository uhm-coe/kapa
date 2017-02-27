module Kapa::PracticumLogBase
  extend ActiveSupport::Concern

  included do
    belongs_to :practicum_placement
    belongs_to :user
    validates_presence_of :log_date
    serialize :task, Kapa::CsvSerializer
    serialize :method, Kapa::CsvSerializer
  end

  def type_desc
    return Kapa::Property.lookup_description(:practicum_log_type, type)
  end

  def category_desc
    return Kapa::Property.lookup_description(:practicum_log_category, category)
  end

  def task_desc
    return self.task.map {|t| Kapa::Property.lookup_description("practicum_log_task", t)}.join(", ")
  end

  def method_desc
    return self.method.map {|t| Kapa::Property.lookup_description("practicum_log_tool", t)}.join(", ")
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      placement_logs = Kapa::PracticumLog.eager_load(:practicum_placement => [:person, :practicum_site, :curriculum, {:users => :person}]).order("persons.last_name, persons.first_name, log_date")
      placement_logs = placement_logs.where("practicum_placements.term_id = ?", filter.term_id) if filter.term_id.present?
      placement_logs = placement_logs.where("practicum_placements.type" => filter.placement_type) if filter.placement_type.present?
      placement_logs = placement_logs.where("practicum_placements.practicum_site_id" => filter.practicum_site_id) if filter.practicum_site_id.present?
      placement_logs = placement_logs.where("practicum_placements.curriculums.program_id" => filter.program_id) if filter.program_id.present?
      placement_logs = placement_logs.where("practicum_placements.curriculums.distribution" => filter.distribution) if filter.distribution.present?
      placement_logs = placement_logs.where("practicum_placements.curriculums.major_primary" => filter.major) if filter.major.present?
      placement_logs = placement_logs.where("practicum_placements.curriculums.cohort" => filter.cohort) if filter.cohort.present?
      placement_logs = placement_logs.where("practicum_logs.user_id" => filter.user_id) if filter.user_id.present?

      case filter.user.access_scope(:kapa_practicum_logs)
        when 30
          # do nothing
        when 20
          placement_logs = placement_logs.column_contains({"practicum_placements.dept" => filter.user.depts}, "user_assignments.user_id = #{filter.user.id}")
        when 10
          placement_logs = placement_logs.assigned_scope(filter.user.id)
        else
          placement_logs = placement_logs.none
      end
      logger.debug "*DEBUG* #{placement_logs.to_sql}"
      return placement_logs
    end

    def csv_format
      {:id_number => [:practicum_placement, :person, :id_number],
       :last_name => [:practicum_placement, :person, :last_name],
       :first_name => [:practicum_placement, :person, :first_name],
       :email => [:practicum_placement, :person, :email],
       :placmenet_type => [:practicum_placement, :type],
       :term => [:practicum_placement, :term_desc],
       # :mentor_person_id => [:practicum_placement, :mentor_person_id],
       # :mentor_last_name => [:practicum_placement, :mentor, :last_name],
       # :mentor_first_name => [:practicum_placement, :mentor, :first_name],
       # :mentor_email => [:practicum_placement, :mentor, :email],
       :site_code => [:practicum_placement, :practicum_site, :code],
       :site_name => [:practicum_placement, :practicum_site, :name],
       :assignee_1_uid => [:practicum_placement, :users, :first, :uid],
       :assignee_1_last_name => [:practicum_placement, :users, :first, :person, :last_name],
       :assignee_1_first_name => [:practicum_placement, :users, :first, :person, :first_name],
       :assignee_2_uid => [:practicum_placement, :users, :second, :uid],
       :assignee_2_last_name => [:practicum_placement, :users, :second, :person, :last_name],
       :assignee_2_first_name => [:practicum_placement, :users, :second, :person, :first_name],
       :log_date => [:log_date],
       :log_type => [:type],
       :duration => [:duration],
       :frequency => [:frequency],
       :task => [:task_desc],
       :method => [:method_desc],
       :note => [:note]}
    end
  end
end
