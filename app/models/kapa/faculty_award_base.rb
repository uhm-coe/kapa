module Kapa::FacultyAwardBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    belongs_to :faculty_service_activity

    has_attached_file :image
    # validates_attachment_content_type :thumbnail, content_type: /\Aimage/ # TODO: Requires Paperclip >4.0

    validates_presence_of :person_id
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      awards = Kapa::FacultyAward.eager_load([:person, :faculty_service_activity]).order("persons.last_name, persons.first_name")
      awards = awards.column_matches("faculty_awards.name" => filter.name) if filter.name.present?
      awards = awards.column_matches("faculty_awards.affiliation" => filter.affiliation) if filter.affiliation.present?
      awards = awards.where("faculty_awards.context" => filter.context) if filter.context.present?
      awards = awards.where(:award_date => filter.award_date_start..filter.award_date_end) if filter.award_date_start.present? and filter.award_date_end.present?
      return awards
    end

    def csv_format
      {:id_number => [:person, :id_number],
       :last_name => [:person, :last_name],
       :first_name => [:person, :first_name],
       :cur_street => [:person, :cur_street],
       :cur_city => [:person, :cur_city],
       :cur_state => [:person, :cur_state],
       :cur_postal_code => [:person, :cur_postal_code],
       :cur_phone => [:person, :cur_phone],
       :email => [:person, :email],
       :award_name => [:name],
       :award_date => [:award_date],
       :affiliation => [:affiliation],
       :description => [:description],
       :url => [:url],
       :context => [:context],
       :service_name => [:faculty_service_activity, :name],
       :service_type => [:faculty_service_activity, :service_type]}
    end
  end
end
