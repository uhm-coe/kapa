class PracticumPlacement < KapaBaseModel
  belongs_to :person
  belongs_to :curriculum
  belongs_to :term
  belongs_to :practicum_site
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
