class Program < ApplicationBaseModel
  attr_accessor :available_majors, :available_distributions, :available_tracks
  has_many :program_offers
  has_many :curriculums

  validates_uniqueness_of :code
  validates_presence_of :code

  before_validation :remove_extra_values
  before_save :join_attributes

  def remove_extra_values
    remove_values(self.available_majors)
    remove_values(self.available_distributions)
    remove_values(self.available_tracks)
  end

  def join_attributes
    self.available_major = @available_majors ? @available_majors.join(",") : "" if @available_majors
    self.available_distribution = @available_distributions ? @available_distributions.join(",") : "" if @available_distributions
    self.available_track = @available_tracks ? @available_tracks.join(",") : "" if @available_tracks
  end

  def degree_desc
    return ApplicationProperty.lookup_description(:degree, degree)
  end

  def self.selections(options = {})
    options[:value] = :code if options[:value].nil?
    programs = where(:active => true, :name => options[:name].to_s)
    programs = programs.where{dept.like_any my{options[:depts].collect {|c| "%#{c}%"}}} if options[:depts]
    programs = programs.where(options[:conditions]) if options[:conditions]
    programs.order("sequence DESC, code").collect do |v|
      value = v.send(options[:value])
      description = ""
      description << "#{value}/" if options[:include_code]
      description << v.description
      [description, value]
    end
  end

  def self.search(filter, options = {})
    programs = Program.scoped
    programs = programs.where{self.dept =~ "%#{filter.dept}%"} if filter.dept.present?
    programs = programs.where("programs.active" => filter.active) if filter.active.present?
    return programs
  end
end
