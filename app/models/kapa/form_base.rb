module Kapa::FormBase
  extend ActiveSupport::Concern

  included do
    self.inheritance_column = nil
    belongs_to :person
    belongs_to :term
    has_one :transition_point
    validates_presence_of :person_id, :type
  end

  def term_desc
    return term_id.blank? ? "No term chosen" : Kapa::Term.find(term_id).description
  end

  def type_desc
    return Kapa::Property.lookup_description(:form, type)
  end

  def lock?
    lock == "Y"
  end

  def submit
    self.update_attributes(:submitted_at => DateTime.now, :lock => "Y")
  end

  def date
    self.submitted_at
  end

  def name
    if self.term_id.blank?
      type_desc
    else
      "#{type_desc} (#{term_desc})"
    end
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      forms = Kapa::Form.eager_load([:person]).order("persons.last_name, persons.first_name")
      forms = forms.where("forms.term_id" => filter.term_id) if filter.term_id.present?
      forms = forms.where("forms.type" => filter.type.to_s) if filter.type.present?
      forms = forms.where("forms.lock" => filter.lock) if filter.lock.present?
      exams = forms.depts_scope(filter.user.depts, "public = 'Y'")
      return forms
    end

    def csv_format
      {:id_number => [:person, :id_number],
       :last_name => [:person, :last_name],
       :first_name => [:person, :first_name],
       :cur_street => [:person, :contact, :cur_street],
       :cur_city => [:person, :contact, :cur_city],
       :cur_state => [:person, :contact, :cur_stateperson, :contact, :cur_state],
       :cur_postal_code => [:person, :contact, :cur_postal_code],
       :cur_phone => [:person, :contact, :cur_phone],
       :email => [:person, :contact, :email],
       :updated => [:updated_at],
       :submitted => [:submitted_at],
       :lock =>[:lock]}
    end
  end
end
