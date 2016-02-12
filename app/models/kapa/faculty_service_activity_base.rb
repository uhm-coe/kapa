module Kapa::FacultyServiceActivityBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    has_many :faculty_awards

    has_attached_file :image
    # validates_attachment_content_type :thumbnail, content_type: /\Aimage/ # TODO: Requires Paperclip >4.0

    validates_presence_of :person_id
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      service_activities = Kapa::FacultyServiceActivity.eager_load([:person]).order("persons.last_name, persons.first_name")
      service_activities = service_activities.where("faculty_service_activities.name" => filter.name) if filter.name.present?
      service_activities = service_activities.where("faculty_service_activities.affiliation" => filter.affiliation) if filter.affiliation.present?
      service_activities = service_activities.where("faculty_service_activities.service_type" => filter.service_type) if filter.service_type.present?
      service_activities = service_activities.where("faculty_service_activities.context" => filter.context) if filter.context.present?
      service_activities = service_activities.where("faculty_service_activities.service_date_start >= ?", filter.service_date_start) if filter.service_date_start.present?
      service_activities = service_activities.where("faculty_service_activities.service_date_end <= ?", filter.service_date_end) if filter.service_date_end.present?
      return service_activities
    end

    def csv_format
      {:id_number => [:person, :id_number],
       :last_name => [:person, :last_name],
       :first_name => [:person, :first_name],
       :cur_street => [:person, :contact, :cur_street],
       :cur_city => [:person, :contact, :cur_city],
       :cur_state => [:person, :contact, :cur_state],
       :cur_postal_code => [:person, :contact, :cur_postal_code],
       :cur_phone => [:person, :contact, :cur_phone],
       :email => [:person, :contact, :email],
       :service_type => [:service_type],
       :service_date_start => [:service_date_start],
       :service_date_end => [:service_date_end],
       :affiliation => [:affiliation],
       :role => [:role],
       :service_name => [:name],
       :compensation => [:compensation],
       :context => [:context],
       :description => [:description]}
    end
  end
end
