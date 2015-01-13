class Term < ActiveRecord::Base
  has_many :transition_points
  has_many :forms
  has_many :courses

  def self.selections(options = {})
    selections = []
    terms = Term.where(:active => 1).order("sequence DESC, code")
    terms = temrs.where(options[:condition]) if options[:condition]
    terms.each {|v| selections.push [v.description, v.id]}
    return selections
  end

  #TODO Implement this method using start date and end date.
  def self.current_term
    Term.find_by_code("201530")
  end

  def self.next_term
    self.where("code > ?", self.current_term).order("code").first
  end

end
