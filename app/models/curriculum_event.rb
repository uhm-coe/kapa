class CurriculumEvent < ApplicationModel
  belongs_to :person
  belongs_to :form
  has_one    :contact, :as => :entity
  has_many   :curriculum_actions
  has_one    :last_curriculum_action,
    :class_name => "CurriculumAction",
    :conditions => "curriculum_actions.id =
                            (select a.id
                             from curriculum_actions a
                             where a.curriculum_event_id = curriculum_actions.curriculum_event_id
                             order by sequence desc, action_date desc, id desc
                             limit 1)"
  has_one    :curriculum_admission
  has_one    :curriculum_graduation
  has_one    :practicum_profile,
    :foreign_key => "curriculum_enrollment_id"

  #Self-join associations
  belongs_to :curriculum_enrollment,
    :class_name => "CurriculumEvent",
    #             :conditions => "curriculum_events.context = 'enrollment'",
  :foreign_key => "curriculum_enrollment_id"
  has_many   :curriculum_events,
    :class_name => "CurriculumEvent",
    :conditions => "curriculum_events.context <> 'enrollment'",
    :foreign_key => "curriculum_enrollment_id"

  has_many :assessment_scores, :as => :assessment_scorable
  
  validates_presence_of :academic_period, :context
  validate :only_one_admission_is_allowed

  before_save :format_fields
  after_save :sync_enrollment

  def only_one_admission_is_allowed
    enrollment = self.curriculum_enrollment
    if enrollment
      admission = self.curriculum_enrollment.curriculum_events.first(:conditions => "context = 'admission'")
      if admission and admission.id != self.id and self.context == "admission"
        errors.add_to_base("The program selected already has admission record!")
      end
    end
  end
  
  def format_fields
    case "#{major_primary}-#{degree}"
    when /EESP-BED/
      self.program = "EESP-BED"
    when /.+PD/
      self.program = "PD"
    when /.+PDE/
      self.program = "PDE"
    when /.+MEDT/
      self.program = "TCH-#{degree}"
    when /.+PHD/
      self.program = "#{major_primary == "EDEP" ? "EDEP" : "EDUC"}-#{degree}"
    when /EE.+/
      self.program = "EDEL-#{degree}"
    when /SE.+/
      self.program = "EDSE-#{degree}"
    when /SP.+/
      self.program = "SPED-#{degree}"
    when /KLS.+/
      self.program = "KLS-#{degree}"
    when /KRS.+/
      self.program = "KRS-#{degree}"
    when /DDS.+/
      self.program = "DDS-GCERT"
    else
      self.program = "#{major_primary}-#{degree}"
    end

#    if self.context != "enrollment" and self.curriculum_enrollment.nil?
    if self.context != "enrollment" and self.curriculum_enrollment_id.blank?
      en = self.create_curriculum_enrollment(:context => "enrollment", :person_id => self.person_id, :academic_period => "000000", :status => "N")
      self.curriculum_enrollment_id = en.id
    end    
  end
  
  def sync_enrollment
    if self.context != "enrollment"
      en = self.curriculum_enrollment
      #Check to see if this is the last event. If so, sync curriculum fields.
      logger.debug "-------en.curriculum_events.first: #{en.curriculum_events.first(:order => "academic_period DESC, id DESC").inspect}"
      if self == en.curriculum_events.first(:order => "academic_period DESC, id DESC")  
        sql = "program = '#{self.program}', track = '#{self.track}', degree = '#{self.degree}', distribution = '#{self.distribution}', location = '#{self.location}', major_primary = '#{self.major_primary}', major_secondary = '#{self.major_secondary}'"
        sql << ", status = '#{self.admitted? ? "Y" : "N"}'"
        sql << ", academic_period = '#{self.academic_period}'" if admission?
        CurriculumEvent.update_all(sql, ["id = ?", en.id])
      end
    end

#    if self.context == "graduation" and self.track == "L" and self.last_curriculum_action and self.last_curriculum_action.action == "1"
#      recommendation = self.curriculum_enrollment.curriculum_events.find_by_context("recommendation")
#      if recommendation.nil?
#        recommendation = self.curriculum_enrollment.curriculum_events.create(:context => "recommendation")
#        recommendation.save
#        recommendation.curriculum_actions.create(:action => "1", :action_date => self.last_curriculum_action.action_date, :handled_by => self.last_curriculum_action.handled_by)
#      end      
#    end
  end
  
  def admitted?
    if admission?
      last_action = self.last_curriculum_action
      return (last_action and last_action.action =~ /[1|2]/)
    else
      return true
    end
  end

  def admission?
    self.context == "admission" || self.context == "declaration"
  end
  
  def event
    if self.context == "declaration"
      "Major declaration"
    else
      self.context
    end
  end

  def academic_period_desc
    return ApplicationProperty.lookup_description(:academic_period, academic_period)
  end

  def status_desc
    status_elements = []
    status_elements.push "[#{priority}]" unless priority.blank?
    status_elements.push ApplicationProperty.lookup_description("#{context}_status", status) unless status.blank?
    return status_elements.join(" ")
  end

  def program_desc
    return ApplicationProperty.lookup_description(:program, program)
  end

  def degree_desc
    return ApplicationProperty.lookup_description(:degree, degree)
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

  def major_campus_desc
    return ApplicationProperty.lookup_description(:major, major_campus)
  end

  def distribution_desc
    return ApplicationProperty.lookup_description(:distribution, distribution)
  end

  def code
    [:degree, :major_primary, :distribution, :track].collect {|i| self.send(i)}.delete_if{|i| i.blank?}.join("/")
  end

  def code_desc
    [:degree, :major_primary_desc, :distribution_desc, :track].collect {|i| self.send(i)}.delete_if{|i| i.blank?}.join("/")
  end
end
