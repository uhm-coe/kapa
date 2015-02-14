class Curriculum < ApplicationBaseModel
  belongs_to :person
  belongs_to :program
  belongs_to :user_primary,
             :class_name => "User",
             :foreign_key => "user_primary_id"
  belongs_to :user_secondary,
             :class_name => "User",
             :foreign_key => "user_secondary_id"
  has_many   :transition_points
  has_one    :practicum_profile
  has_one    :last_transition_point,
    :class_name => "TransitionPoint",
    :conditions => "transition_points.id =
                            (select t.id
                             from transition_points t
                             inner join terms tm on tm.id = t.term_id
                             where t.curriculum_id = transition_points.curriculum_id
                             order by tm.sequence desc
                             limit 1)"

  validates_presence_of :person_id, :program_id
  before_create :set_default_options

  def set_default_options
    self.major_primary = self.program.major if self.major_primary.blank?
    self.distribution = self.distribution if self.distribution.blank?
    self.track = self.program.track if self.track.blank?
    self.location = self.program.location if self.location.blank?
  end

  def term_desc
    # TODO: term_id column does not exist
    # return Term.find(term_id).description
    return "Term TBD"
  end

  def track_desc
    return ApplicationProperty.lookup_description(:track, track)
  end

  def major_primary_desc
    return ApplicationProperty.lookup_description(:major, major_primary)
  end

  def major_secondary_desc
    return ApplicationProperty.lookup_description(:major, major_secondary)
  end

  def distribution_desc
    return ApplicationProperty.lookup_description(:distribution, distribution)
  end

  def location_desc
    return ApplicationProperty.lookup_description(:location, location)
  end

  def code
    texts = [program.degree]
    texts.push major_primary if major_primary.present?
    texts.push distribution if distribution.present?
    texts.push track if track.present?
    return texts.join("/")
  end

  def code_desc
    texts = [program.degree]
    texts.push major_primary_desc if major_primary_desc.present?
    texts.push distribution_desc if distribution_desc.present?
    texts.push track_desc if track_desc.present?
    return texts.join("/")
  end

  def self.search(filter, options ={})
    curriculums = Curriculum.includes([:transition_points, :program, :person])#TODO filter admitted studnets .where("transition_actions.action" => ['1','2'])
    curriculums = curriculums.where("transition_points.term_id" => filter.term_id) if filter.term_id.present?
    curriculums = curriculums.where("transition_points.type" => filter.type.to_s) if filter.type.present?
    curriculums = curriculums.where("programs.code" => filter.program) if filter.program.present?
    curriculums = curriculums.where("curriculums.distribution" => filter.distribution) if filter.distribution.present?
    curriculums = curriculums.where("curriculums.major_primary" => filter.major) if filter.major.present?
    curriculums = curriculums.where{({curriculums => user_primary_id} == my{filter.user_id}) | ({curriculums => user_secondary_id} == my{filter.user_id})} if filter.user_id.present?

    case filter.user.access_scope
    when 3
      # do nothing
    when 2
      curriculums = curriculums.where("programs.code" => filter.user.depts)
    when 1
      curriculums = curriculums.where{({curriculums => user_primary_id} == my{filter.user.id}) | ({curriculums => user_secondary_id} == my{filter.user.id})}
    else
      curriculums = curriculums.where("1 = 2")  #Do not list any objects
    end
    return curriculums
  end

  def self.to_csv(filter, options ={})
    transition_points = self.search(filter).order( "persons.last_name, persons.first_name")
    CSV.generate do |csv|
      csv << self.csv_columns
      transition_points.each do |c|
        csv << csv_row(c)
      end
    end
  end

  def self.csv_columns
    [:id_number,
     :last_name,
     :first_name,
     :email,
     :email_alt,
     :ssn,
     :ssn_agreement,
     :cur_street,
     :cur_city,
     :cur_state,
     :cur_postal_code,
     :cur_phone,
     :curriculum_id,
  #   :term_desc,
     :program_desc,
     :track_desc,
     :major_primary_desc,
     :major_secondary_desc,
     :distribution_desc,
     :second_degree]
  end

  def self.csv_row(c)
    [c.rsend(:person, :id_number),
     c.rsend(:person, :last_name),
     c.rsend(:person, :first_name),
     c.rsend(:person, :email),
     c.rsend(:person, :contact, :email_alt),
     c.rsend(:person, :ssn),
     c.rsend(:person, :ssn_agreement),
     c.rsend(:person, :contact, :cur_street),
     c.rsend(:person, :contact, :cur_city),
     c.rsend(:person, :contact, :cur_state),
     c.rsend(:person, :contact, :cur_postal_code),
     c.rsend(:person, :contact, :cur_phone),
     c.rsend(:id),
 #    c.rsend(:term, :description),
     c.rsend(:program, :description),
     c.rsend(:track_desc),
     c.rsend(:major_primary_desc),
     c.rsend(:major_secondary_desc),
     c.rsend(:distribution_desc),
     c.rsend(:second_degree)]
  end
end
