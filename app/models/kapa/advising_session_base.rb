module Kapa::AdvisingSessionBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    belongs_to :user_primary,
               :class_name => "User",
               :foreign_key => "user_primary_id"
    belongs_to :user_secondary,
               :class_name => "User",
               :foreign_key => "user_secondary_id"
    validates_presence_of :person_id, :session_date, :session_type
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      advising_sessions = Kapa::AdvisingSession.eager_load([:person => :contact]).order("session_date DESC, advising_sessions.id DESC")
      advising_sessions = advising_sessions.where(:session_date => filter.date_start..filter.date_end) if filter.date_start.present? and filter.date_end.present?
      advising_sessions = advising_sessions.where(:task => filter.task) if filter.task.present?
      advising_sessions = advising_sessions.where(:interest => filter.interest) if filter.interest.present?
      advising_sessions = advising_sessions.assigned_scope(filter.user_id) if filter.user_id.present?

      case filter.user.access_scope
        when 3
          # Do nothing
        when 2
          advising_sessions = advising_sessions.depts_scope(filter.user.depts)
        when 1
          advising_sessions = advising_sessions.assigned_scope(filter.user.id)
        else
          advising_sessions = advising_sessions.where("0 = 1")
      end
      return advising_sessions
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
       :session_date => [:classification],
       :session_type => [:session_type],
       :task => [:task],
       :classification => [:classification],
       :interest => [:interest],
       :location => [:location],
       :handled_by => [:handled_by]}
    end
  end
end
