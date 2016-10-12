module Kapa::TermBase
  extend ActiveSupport::Concern

  included do
    has_many :transition_points
    has_many :forms
    has_many :courses
    has_many :advising_sessions
    validates_presence_of :code, :description
    before_create :set_id
  end

  def set_id
    self.id = self.code.to_i if self.code =~ /\A[-+]?[0-9]+\z/
  end

  def next_term
    Kapa::Term.where("code > ?", self.code).order("code").first
  end

  class_methods do

    def selections(options = {})
      selections = []
      terms = Kapa::Term.where(:active => true).order("sequence DESC, code")
      terms = terms.where(options[:conditions]) if options[:conditions].present?
      terms.each { |v| selections.push [v.description, v.id] }
      return selections
    end

    def current_term
      Kapa::Term.where("? between start_date and end_date", Date.today).last or Kapa::Term.find_by_code("201630")
    end

    def next_term
      self.where("code > ?", self.current_term.code).order("code").first
    end

    #def terms_ids_by_range(start_term_id, end_term_id)
    #  self.where(:code => Kapa::Term.find(start_term_id).code..Kapa::Term.find(end_term_id).code).order(:sequence).collect { |t| t.id }
    #end

    def lookup_description(id)
      term = Kapa::Term.find_by_id(id)
      if term
        return term.description
      else
        return "N/A"
      end
    end

    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      terms = Kapa::Term.all.order("sequence DESC, code")
      terms = terms.where("start_date >= :start_date", {:start_date => filter.start_date}) if filter.start_date.present?
      terms = terms.where("end_date <= :end_date", {:end_date => filter.end_date}) if filter.end_date.present?
      terms = terms.where("active" => filter.active) if filter.active.present?
      return terms
    end
  end
end
