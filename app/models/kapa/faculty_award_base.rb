module Kapa::FacultyAwardBase
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
      awards = Kapa::FacultyAward.eager_load([:person]).order("persons.last_name, persons.first_name")
      awards = awards.where("faculty_awards.name LIKE ?", "%#{filter.name}%") if filter.name.present?
      awards = awards.where("faculty_awards.affiliation LIKE ?", "%#{filter.affiliation}%") if filter.affiliation.present?
      awards = awards.where("faculty_awards.context" => filter.context) if filter.context.present?
      awards = awards.where(:award_date => filter.award_date_start..filter.award_date_end) if filter.award_date_start.present? and filter.award_date_end.present?
      return awards
    end
  end
end
