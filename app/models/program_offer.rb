class ProgramOffer < KapaBaseModel
  attr_accessor :available_majors, :available_term_ids
  belongs_to :program

  validates_uniqueness_of :distribution, :scope => :program_id
  validates_presence_of :distribution

  before_validation :remove_extra_values
  before_save :join_attributes

  def remove_extra_values
    self.available_majors.delete_if {|x| x.blank? || x == "multiselect-all"} if self.available_majors
    self.available_term_ids.delete_if {|x| x.blank? || x == "multiselect-all"} if self.available_term_ids
  end

  def join_attributes
    self.available_major = @available_majors ? @available_majors.join(",") : "" if @available_majors
    self.available_term_id = @available_term_ids ? @available_term_ids.join(",") : "" if @available_term_ids
  end

  def self.selections(options = {})
    options[:value] = :distribution if options[:value].nil?
    program_offers = where(:active => true)
    program_offers = program_offers.where{dept.like_any my{options[:depts].collect {|c| "%#{c}%"}}} if options[:depts]
    program_offers = program_offers.where(options[:conditions]) if options[:conditions]
    program_offers.order("sequence DESC, distribution").collect do |v|
      value = v.send(options[:value])
      description = ""
      description << "#{value}/" if options[:include_code]
      description << v.description
      [description, value]
    end
  end

end
