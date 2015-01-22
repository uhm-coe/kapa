class Program < ApplicationBaseModel
  attr_accessor :available_majors, :available_distributions, :available_tracks
  has_many :program_offers
  has_many :curriculums

  validates_uniqueness_of :code
  validates_presence_of :code

  before_save :join_attributes

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
    filter = ApplicationFilter.new
    filter.append_condition("active = 1")
    filter.append_depts_condition("dept like ?", options[:depts]) if options[:depts]
    filter.append_condition(options[:conditions]) if options[:conditions]
    selections = []

    Program.find(:all, :conditions => filter.conditions, :order => "sequence DESC, code").each do |v|
      value = v.send(options[:value])
      description = ""
      description << "#{value}/" if options[:include_code]
      description << v.description
      selections.push [description, value]
      options[:include_value] = nil if value.to_s == options[:include_value].to_s
    end
    #This is needed to eliminate a blank field.
    options[:include_value] = nil if options[:include_value] == "" and options[:include_blank]
    #If the current value does not exist in the list, we have to add it manually.
    selections = [[options[:include_value], options[:include_value]]] + selections if options[:include_value]
    return selections
  end

end
