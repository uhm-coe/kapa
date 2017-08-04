module Kapa::FormBase
  extend ActiveSupport::Concern

  included do
    belongs_to :form_template
    belongs_to :file
    belongs_to :person
    belongs_to :term
    belongs_to :attachable, :polymorphic => true
    has_many :user_assignments, :as => :assignable
    has_many :users, :through => :user_assignments

    validates_presence_of :form_template_id

  end

  def term_desc
    return (term_id.blank? or term_id == 0) ? "No term chosen" : Kapa::Term.find(term_id).description
  end

  def type
    return "Form"
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
      self.form_template.title
    else
      "#{self.form_template.title} (#{term_desc})"
    end
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      forms = Kapa::Form.eager_load({:users => :person}, :person).order("forms.submitted_at DESC")
      forms = forms.where("forms.term_id" => filter.term_id) if filter.form_term_id.present?
      forms = forms.where("forms.type" => filter.form_type.to_s) if filter.form_type.present?
      forms = forms.where("forms.lock" => filter.lock) if filter.lock.present?

      case filter.user.access_scope(:kapa_forms)
        when 30
          # do nothing
        when 20
          forms = forms.depts_scope(filter.user.depts, filter.user.id, "public = 'Y'")
        when 10
          forms = forms.assigned_scope(filter.user.id)
        else
          forms = forms.none
      end

      return forms
    end

    def csv_format
      {:id_number => [:person, :id_number],
       :last_name => [:person, :last_name],
       :first_name => [:person, :first_name],
       :cur_street => [:person, :cur_street],
       :cur_city => [:person, :cur_city],
       :cur_state => [:person, :cur_state],
       :cur_postal_code => [:person, :cur_postal_code],
       :cur_phone => [:person, :cur_phone],
       :email => [:person, :email],
       :email_alt => [:person, :email_alt],
       :updated => [:updated_at],
       :submitted => [:submitted_at],
       :lock =>[:lock]}
    end
  end
end
