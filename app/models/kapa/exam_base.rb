module Kapa::ExamBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    has_many :exam_scores
    belongs_to :attachable, :polymorphic => true
    before_save :format_fields
    validates_presence_of :person_id
  end

  def format_fields
    self.raw[5..13] = "000000000" #Mask SSN
  end

  def type_desc
    return Kapa::Property.lookup_description(:exam, type)
  end

  def name
    "#{type_desc} (#{self.report_number})"
  end

  def date
    self.report_date
  end

  def parse
    ActiveRecord::Base.transaction do
      self.report_number = extract_report_number
      self.report_date = Date.strptime(extract_value(435, 442), '%Y%m%d')

      examinee_profile =
          {:ets_id => extract_value(15, 22),
           :last_name => extract_value(23, 37),
           :first_name => extract_value(38, 47),
           :middle_initial => extract_value(48, 48),
           :birth_date => Date.strptime(extract_value(50, 57), '%Y%m%d'),
           :gender => extract_value(49, 49),
           :ethnicity => extract_value(132, 134),
           :attending_institution => extract_value(116, 119),
           :educational_level => extract_value(120, 122),
           :undergraduate_gpa => extract_value(129, 131),
           :undergraduate_major => extract_value(123, 125),
           :graduate_major => extract_value(126, 128),
           :low_value_filler => extract_value(135, 140)}
      self.serialize(:examinee_profile, examinee_profile)
      examinee_contact =
          {:street => extract_value(58, 87),
           :city => extract_value(88, 101),
           :state => extract_value(102, 103),
           :postal_code => extract_value(104, 112),
           :contry => extract_value(113, 115)}
      self.serialize(:examinee_contact, examinee_contact)
      if self.person.nil?
        p = Kapa::Person.first(:conditions => ["last_name like ? and birth_date = ?", examinee_profile[:last_name], examinee_profile[:birth_date]])
        if p
          self.person = p
          self.status = 'M'
        else

          self.create_person(:last_name => examinee_profile[:last_name].capitalize,
                             :first_name => examinee_profile[:first_name].capitalize,
                             :birth_date => examinee_profile[:birth_date])
          self.status = 'U'
        end
      end
      self.save!

      self.exam_scores.clear
      for i in (1..36)
        shift = (i - 1) * 42
        subject = extract_value(455, 458, shift)
        if not subject.blank? and subject =~ /^[0-9]+/
          exam_score = self.exam_scores.build(
              {:taken_date => Date.strptime(extract_value(445, 454, shift), '%m/%d/%Y'),
               :subject => extract_value(455, 458, shift),
               :score => extract_value(459, 462, shift),
               :required_score => "#{extract_value(463, 465, shift)}#{extract_value(473, 476, shift)}",
               :status => "#{extract_value(466, 472, shift)}#{extract_value(477, 486, shift)}"})
          exam_score.serialize(:subscores, [])
          exam_score.save!
        end
      end
      #This must be a separate loop because the order of score and subscore are inconsistent.
      for i in (1..36)
        shift_exam = (i - 1) * 700
        subject = extract_value(1965, 1968, shift_exam)
#        logger.debug "(i):(#{i}) subject: #{subject}"
        if subject.blank?
          exam_score = nil
        else
          exam_score = self.exam_scores.find_by_subject(subject)
        end
        if exam_score
          subscores = []
          for j in (1..8)
            shift_sub = shift_exam + (j - 1) * 87
#            logger.debug "(i,j):(#{i},#{j}) shift: #{shift_sub}, #{shift_sub+1969} category: #{extract_value(1969, 2043, shift_sub)}"
            if not extract_value(1969, 2043, shift_sub).blank?
              exam_score.[]=("category_points_0#{j}", extract_value(2044, 2046, shift_sub))
              subscores.push({:category_number => j,
                              :category_text => extract_value(1969, 2043, shift_sub),
                              :category_points => extract_value(2044, 2046, shift_sub),
                              :category_points_max => extract_value(2047, 2049, shift_sub),
                              :category_25th_raw => extract_value(2050, 2052, shift_sub),
                              :category_75th_raw => extract_value(2053, 2055, shift_sub)})
            end
          end
          exam_score.serialize(:subscores, subscores)
          exam_score.save!
        end
      end

      return true
    end

    return false
  end

  def check_format
    extract_value(429, 434) == "PRAXIS"
  end

  def extract_report_number
    "#{extract_value(15, 22)}-#{extract_value(435, 442)}"
  end

  def extract_value(start_position, end_position, shift = 0)
    raw[(start_position - 1 + shift)..(end_position - 1 + shift)].to_s.strip
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      exams = Kapa::Exam.eager_load([:person, :exam_scores]).order("report_date DESC, persons.last_name, persons.first_name")
      exams = exams.where("persons.last_name || ', ' || persons.first_name like ?", "%#{filter.name}%") if filter.name.present?
      exams = exams.where("persons.birth_date" => filter.birth_date) if filter.birth_date.present?
      exams = exams.where(:report_date => filter.exam_date_start..filter.exam_date_end) if filter.exam_date_start.present? and filter.exam_date_end.present?
      exams = exams.depts_scope(filter.user.depts, "public = 'Y'")
      return exams
    end
  end
end
