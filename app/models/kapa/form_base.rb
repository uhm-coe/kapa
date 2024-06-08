module Kapa::FormBase
  extend ActiveSupport::Concern

  included do
    belongs_to :form_template
    belongs_to :person, :optional => true
    belongs_to :attachable, :polymorphic => true, :optional => true
    has_many :files, :as => :attachable
    has_many :user_assignments, :as => :assignable
    has_many :users, :through => :user_assignments

    validates_presence_of :form_template_id
  end

  def document_id
    "FR" + self.id.to_s.rjust(8, '0')
  end

  def document_type
    return "Form"
  end

  def document_title
    if self.term.blank?
      self.form_template.title
    else
      "#{self.form_template.title} (#{term_desc})"
    end
  end

  def document_date
    self.submitted_at
  end

  def lock?
    lock == "Y"
  end

  def submit
    self.update(:submitted_at => DateTime.now, :lock => "Y", :active => true)
  end

  def term_desc
    self.desc_of(:term)
  end

  def status_desc
    self.desc_of(:status)
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      forms = Kapa::Form.eager_load({:users => :person}, :person, :form_template).where(:active => true).order("forms.submitted_at DESC")
      forms = forms.where("forms.form_template_id" => filter.form_template_id) if filter.form_template_id.present?
      forms = forms.where("forms.term" => filter.form_term) if filter.form_term.present?
      forms = forms.where("forms.lock" => filter.lock) if filter.lock.present?
      forms = forms.depts_scope(filter.user.depts) if filter.depts.present?

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

    # def csv_format
    #   {:id_number => [:person, :id_number],
    #    :last_name => [:person, :last_name],
    #    :first_name => [:person, :first_name],
    #    :cur_street => [:person, :cur_street],
    #    :cur_city => [:person, :cur_city],
    #    :cur_state => [:person, :cur_state],
    #    :cur_postal_code => [:person, :cur_postal_code],
    #    :cur_phone => [:person, :cur_phone],
    #    :email => [:person, :email],
    #    :updated => [:updated_at],
    #    :submitted => [:submitted_at],
    #    :lock =>[:lock]}
    # end
  end
end
