module Kapa::FacultyServiceActivityBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person

    has_attached_file :image
    # validates_attachment_content_type :thumbnail, content_type: /\Aimage/ # TODO: Requires Paperclip >4.0

    validates_presence_of :person_id
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      service_activities = Kapa::FacultyServiceActivity.eager_load([:person]).order("persons.last_name, persons.first_name")
      service_activities = service_activities.where("faculty_service_activities.name LIKE ?", "%#{filter.name}%") if filter.name.present?
      service_activities = service_activities.where("faculty_service_activities.affiliation LIKE ?", "%#{filter.affiliation}%") if filter.affiliation.present?
      service_activities = service_activities.where("faculty_service_activities.service_type" => filter.service_type) if filter.service_type.present?
      service_activities = service_activities.where("faculty_service_activities.context" => filter.context) if filter.context.present?
      service_activities = service_activities.where(:pubdate => filter.pubdate_start..filter.pubdate_end) if filter.pubdate_start.present? and filter.pubdate_end.present?
      return service_activities
    end
  end
end
