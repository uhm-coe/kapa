class PracticumAssignment < ApplicationModel
  belongs_to :practicum_placement
  belongs_to :practicum_school
  belongs_to :person
  belongs_to :user_primary,
             :class_name => "User",
             :foreign_key => "user_primary_id"
  belongs_to :user_secondary,
             :class_name => "User",
             :foreign_key => "user_secondary_id"

  def mentor?
    self.assignment_type == "mentor"
  end
end
