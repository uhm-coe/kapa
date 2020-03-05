module Kapa::TextBase
  extend ActiveSupport::Concern

  included do
    belongs_to :text_template
    belongs_to :person, :optional => true
    belongs_to :attachable, :polymorphic => true, :optional => true
    has_many :files, :as => :attachable
    has_many :user_assignments, :as => :assignable
    has_many :users, :through => :user_assignments

    property_lookup :status

    #validates_presence_of :text_template_id
    after_create :set_default_contents, :replace_variables
  end

  def document_id
    "LT" + self.id.to_s.rjust(8, '0')
  end

  def type
    return "Letter"
  end

  def date
    self.submitted_at
  end

  def status

  end

  def lock?
    lock == "Y"
  end

  def submit
    self.update_attributes(:submitted_at => DateTime.now, :lock => "Y")
  end

  def set_default_contents
    self.title = self.text_template.title
    self.body = self.text_template.body
    self.save
  end

  def replace_variables
  end

  def generate_pdf(options = {})
    locals = options[:locals] || {}
    locals[:@text] = self
    html = ApplicationController.render(self.text_template.template_path, :layout => nil, :locals => locals)
    logger.debug "*DEBUG* #{html}"
    pdf_contents = WickedPdf.new.pdf_from_string(html)
    pdf = Kapa::File.new
    pdf.name = "#{self.title}.pdf"
    pdf.data = StringIO.new(pdf_contents)
    pdf.data_file_name = pdf.name
    pdf.data_content_type = "application/pdf"
    pdf.attachable = self
    pdf.person = self.person if self.person
    pdf.save!
    return pdf
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
  end
end
