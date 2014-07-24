class AdvisingSession < ApplicationModel
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
end
