class AdvisingSession < KapaBaseModel
  belongs_to :person
  belongs_to :template
  has_one :contact, :as => :entity
  has_many :advising_actions
  belongs_to :user_primary,
             :class_name => "User",
             :foreign_key => "user_primary_id"
  belongs_to :user_secondary,
             :class_name => "User",
             :foreign_key => "user_secondary_id"

  validates_presence_of :session_date
  validates_presence_of :session_type

  def name
    if anonymous?
      return "#{identity_note}*"
    else
      return self.person.full_name
    end
  end

  def anonymous?
    return person_id == 0
  end

  def self.search(filter, options = {})
    advising_sessions = AdvisingSession.includes([:person => :contact])
    advising_sessions = advising_sessions.where("handled_by" => filter.handled_by) if filter.handled_by.present?
    advising_sessions = advising_sessions.where{self.session_date >= filter.date_start} if filter.date_start.present?
    advising_sessions = advising_sessions.where{self.session_date <= filter.date_end} if filter.date_end.present?
    advising_sessions = advising_sessions.where("task" => filter.task) if filter.task.present?
    advising_sessions = advising_sessions.where("interest" => filter.interest) if filter.interest.present?

    case filter.user.access_scope
    when 3
      # Do nothing
    when 2
      advising_sessions = advising_sessions.where{self.dept.like_any filter.user.depts} unless filter.user.manage? :advising
    when 1
      advising_sessions = advising_sessions.where{({advising_sessions => user_primary_id} == my{filter.user.id}) | ({advising_sessions => user_secondary_id} == my{filter.user.id})}
    else
      advising_sessions = advising_sessions.where("1 = 2")
    end
    return advising_sessions
  end

  def self.to_csv(filter, options = {})
    advising_sessions = self.search(filter).order("session_date DESC, advising_sessions.id DESC")
    CSV.generate do |csv|
      csv << self.csv_columns
      advising_sessions.each do |c|
        csv << self.csv_row(c)
      end
    end
  end

  def self.csv_columns
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

  def self.csv_row(c)
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
