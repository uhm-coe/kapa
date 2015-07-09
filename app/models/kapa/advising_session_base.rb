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
    def search(filter, options = {})
      advising_sessions = Kapa::AdvisingSession.eager_load([:person => :contact])
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

    def to_csv(filter, options = {})
      advising_sessions = self.search(filter).order("session_date DESC, advising_sessions.id DESC")
      CSV.generate do |csv|
        csv << self.csv_columns
        advising_sessions.each do |c|
          csv << self.csv_row(c)
        end
      end
    end

    def csv_columns
      [:id_number,
       :last_name,
       :first_name,
       :cur_street,
       :cur_city,
       :cur_state,
       :cur_postal_code,
       :cur_phone,
       :email,
       :session_date,
       :session_type,
       :task,
       :classification,
       :interest,
       :location,
       :handled_by]
    end

    def csv_row(c)
      [c.rsend(:person, :id_number),
       c.rsend(:person, :last_name),
       c.rsend(:person, :first_name),
       c.rsend(:person, :contact, :cur_street),
       c.rsend(:person, :contact, :cur_city),
       c.rsend(:person, :contact, :cur_state),
       c.rsend(:person, :contact, :cur_postal_code),
       c.rsend(:person, :contact, :cur_phone),
       c.rsend(:person, :contact, :email),
       c.rsend(:session_date),
       c.rsend(:session_type),
       c.rsend(:task),
       c.rsend(:classification),
       c.rsend(:interest),
       c.rsend(:location),
       c.rsend(:handled_by)]
    end

  end
end
