module Kapa::AdvisingSessionBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    belongs_to :term
    belongs_to :curriculum
    has_many :user_assignments, :as => :assignable
    has_many :users, :through => :user_assignments

    validates_presence_of :person_id, :session_date, :type
  end

  def term_desc
    Kapa::Term.lookup_description(self.term_id)
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      advising_sessions = Kapa::AdvisingSession.eager_load([:user_assignments, :person]).order("session_date DESC, advising_sessions.id DESC")
      advising_sessions = advising_sessions.where(:session_date => filter.date_start..filter.date_end) if filter.date_start.present? and filter.date_end.present?
      advising_sessions = advising_sessions.where(:task => filter.task) if filter.task.present?
      advising_sessions = advising_sessions.where(:interest => filter.interest) if filter.interest.present?
      advising_sessions = advising_sessions.assigned_scope(filter.user_id) if filter.user_id.present?

      case filter.user.access_scope
        when 30
          # Do nothing
        when 20
          advising_sessions = advising_sessions.depts_scope(filter.user.depts, filter.user.id)
        when 10
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
       :cur_street => [:person, :cur_street],
       :cur_city => [:person, :cur_city],
       :cur_state => [:person, :cur_state],
       :cur_postal_code => [:person, :cur_postal_code],
       :cur_phone => [:person, :cur_phone],
       :email => [:person, :email],
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
