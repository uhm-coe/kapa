class Term < KapaBaseModel
  has_many :transition_points
  has_many :forms
  has_many :courses
  validates_presence_of :code, :description
  before_create :set_id

  def set_id
    self.id = self.code.to_i if self.code =~ /\A[-+]?[0-9]+\z/
  end

  def self.selections(options = {})
    selections = []
    terms = Term.where(:active => true).order("sequence DESC, code")
    terms = temrs.where(options[:condition]) if options[:condition]
    terms.each { |v| selections.push [v.description, v.id] }
    return selections
  end

  #TODO Implement this method using start date and end date.
  def self.current_term
    Term.find_by_code("201530")
  end

  def self.next_term
    self.where("code > ?", self.current_term.code).order("code").first
  end

  def self.terms_ids_by_range(start_term_id, end_term_id)
    self.where(:code => Term.find(start_term_id).code..Term.find(end_term_id).code).order(:sequence).collect { |t| t.id }
  end

  def self.search(filter, options = {})
    # To return an ActiveRecord::Relation, use the following:
    #   For Rails 4.1 and above: Term.all
    #   For Rails 4.0: Term.where(nil)
    #   For Rails 3.x: Term.scoped
    terms = Term.scoped
    terms = terms.where("id" => filter.term_id) if filter.term_id.present?
    terms = terms.where("start_date >= :start_date", {:start_date => filter.start_date}) if filter.start_date.present?
    terms = terms.where("end_date <= :end_date", {:end_date => filter.end_date}) if filter.end_date.present?
    terms = terms.where("active" => filter.active) if filter.active.present?
    return terms
  end
end
