class PracticumPlacement < KapaBaseModel
  belongs_to :person
  belongs_to :curriculum
  belongs_to :term
  belongs_to :practicum_site
  belongs_to :mentor,
             :class_name => "Person",
             :foreign_key => "mentor_person_id"
  belongs_to :user_primary,
             :class_name => "User",
             :foreign_key => "user_primary_id"
  belongs_to :user_secondary,
             :class_name => "User",
             :foreign_key => "user_secondary_id"

  def term_desc
    return Term.find(term_id).description
  end
end
