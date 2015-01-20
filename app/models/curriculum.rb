class Curriculum < ApplicationModel
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
                             order by tm.sequence desc, t.id desc
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

#  def degree_desc
#    return Validation.lookup_description(:degree, degree)
#  end

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
end
