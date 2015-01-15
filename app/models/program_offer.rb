class ProgramOffer < ActiveRecord::Base
  attr_accessor :available_majors, :available_term_ids
  belongs_to :program

  validates_uniqueness_of :distribution, :scope => :program_id
  validates_presence_of :distribution

  before_save :join_attributes

  def join_attributes
    self.available_major = @available_majors ? @available_majors.join(",") : "" if @available_majors
    # TODO: available_term_id is not being saved to the database
    self.available_term_ids = @available_term_ids ? @available_term_ids.join(",") : "" if @available_term_ids
  end

  def self.selections(options = {})
    options[:value] = :distribution if options[:value].nil?
    filter = ApplicationFilter.new(:program_id => options[:program].id)
    filter.append_condition("active = 1")
    filter.append_condition("program_id = ?", :program_id)
    filter.append_condition(options[:conditions]) if options[:conditions]
    selections = []

    ProgramOffer.find(:all, :conditions => filter.conditions, :order => "sequence DESC, distribution").each do |v|
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
