module Kapa::TextBase
  extend ActiveSupport::Concern

  included do
    belongs_to :text_template
    belongs_to :person
    belongs_to :attachable, :polymorphic => true
    has_many :user_assignments, :as => :assignable
    has_many :users, :through => :user_assignments

    serialize :dept, Kapa::CsvSerializer

    #validates_presence_of :text_template_id
    after_create :set_default_contents, :replace_variables
  end

  def type_desc
    return Kapa::Property.lookup_description(:text, type)
  end

  def lock?
    lock == "Y"
  end

  def submit
    self.update_attributes(:submitted_at => DateTime.now, :lock => "Y")
  end

  def name
    self.title
  end

  def date
    self.submitted_at
  end

  def set_default_contents
    self.title = self.text_template.title
    self.body = self.text_template.body
    self.save
  end

  def replace_variables
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      texts = Kapa::Text.eager_load({:users => :person}, :person).order("texts.created_at DESC")
      texts = texts.where("texts.term" => filter.term) if filter.text_term.present?
      texts = texts.where("texts.type" => filter.text_type.to_s) if filter.text_type.present?
      texts = texts.where("texts.lock" => filter.lock) if filter.lock.present?

      case filter.user.access_scope(:kapa_texts)
        when 30
          # do nothing
        when 20
          texts = texts.depts_scope(filter.user.depts)
        when 10
          texts = texts.assigned_scope(filter.user.id)
        else
          texts = texts.none
      end

      return texts
    end

    def csv_format
      {:id_number => [:person, :id_number],
       :last_name => [:person, :last_name],
       :first_name => [:person, :first_name],
       :cur_street => [:person, :cur_street],
       :cur_city => [:person, :cur_city],
       :cur_state => [:person, :cur_stateperson, :contact, :cur_state],
       :cur_postal_code => [:person, :cur_postal_code],
       :cur_phone => [:person, :cur_phone],
       :email => [:person, :email],
       :updated => [:updated_at],
       :submitted => [:submitted_at],
       :lock =>[:lock]}
    end
  end
end
