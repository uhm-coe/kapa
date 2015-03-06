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

  def self.search(filter, options = {})
    placements = PracticumPlacement.includes([:person, :practicum_site])
    placements = placements.where("practicum_placements.term_id" => filter.term_id) if filter.term_id.present?
    placements = placements.where("practicum_site_id" => filter.practicum_site_id) if filter.practicum_site_id.present?
    placements = placements.assigned_scope(filter.user_id) if filter.user_id.present?
    return placements
  end

  def self.to_csv(filter, options = {})
    placements = self.search(filter).order("persons.last_name, persons.first_name")
    CSV.generate do |csv|
      csv << self.csv_columns
      placements.each do |c|
        csv << self.csv_row(c)
      end
    end
  end

  def self.csv_columns
   [:id_number,
    :last_name,
    :first_name,
    :email,
    :category,
    # :sequence,
    # :mentor_type,
    :term,
    :status,
    # :total_mentors,
    :mentor_person_id,
    :mentor_last_name,
    :mentor_first_name,
    :mentor_email,
    :site_code,
    :site_name,
    # :content_area,
    :supervisor_1_uid,
    :supervisor_1_last_name,
    :supervisor_1_first_name,
    :supervisor_2_uid,
    :supervisor_2_last_name,
    :supervisor_2_first_name,
    :note]
  end

  def self.csv_row(c)
   [c.rsend(:person, :id_number),
    c.rsend(:person, :last_name),
    c.rsend(:person, :first_name),
    c.rsend(:person, :email),
    c.rsend(:category),
    # c.rsend(:practicum_placement, :sequence), # TODO: No longer exists on practicum_placement
    # c.rsend(:practicum_placement, :mentor_type), # TODO: No longer exists on practicum_placement
    c.rsend(:term, :description),
    c.rsend(:status),
    # c.rsend(:practicum_placement, [:practicum_assignments_select, :mentor], :length), # TODO
    c.rsend(:person_mentor_id),
    c.rsend(:mentor, :last_name),
    c.rsend(:mentor, :first_name),
    c.rsend(:mentor, :contact, :email),
    c.rsend(:practicum_site, :code),
    c.rsend(:practicum_site, :name_short),
    # c.rsend(:content_area), # TODO: Used to be on practicum_assignments
    c.rsend(:user_primary, :uid),
    c.rsend(:user_primary, :person, :last_name),
    c.rsend(:user_primary, :person, :first_name),
    c.rsend(:user_secondary, :uid),
    c.rsend(:user_secondary, :person, :last_name),
    c.rsend(:user_secondary, :person, :first_name),
    c.rsend(:note)]
  end
end
