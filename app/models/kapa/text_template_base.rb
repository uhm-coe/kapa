module Kapa::TextTemplateBase
  extend ActiveSupport::Concern

  included do
    has_many :texts
    # Email templates (type "email") are rendered by the app's mailer; other types are PDF letters.
    scope :emails, -> { where(:type => "email") }
    validates_presence_of :code, :subject, :if => :email?
    validates_uniqueness_of :code, :allow_blank => true
    validate :validate_liquid
    validate :validate_template_path
  end

  def email?
    self.type == "email"
  end

  # This template's entry in the app's registry (title, subject, variables, sample values), or {}.
  def template_config
    self.class.registry(self.type)[self.code] || {}
  end

  def render_subject(locals = {})
    Liquid::Template.parse(self.subject.to_s, :error_mode => :strict).render(locals.stringify_keys)
  end

  # Layouts are rendered outside a request, so URL helpers in them use the app's mail host
  # (config.action_mailer.default_url_options) instead of the renderer's default (example.org).
  def layout_renderer
    url_options = Rails.configuration.action_mailer.default_url_options || {}
    env = {}
    env[:http_host] = url_options[:host] if url_options[:host].present?
    env[:https] = url_options[:protocol].to_s == "https" if url_options[:protocol].present?
    ApplicationController.renderer.new(env)
  end

  # template_path is a layout: "mailer" (app/views/layouts/mailer) or a full path such as "kapa/layouts/letter".
  def layout_path
    return nil if self.template_path.blank?
    path = self.template_path.delete_prefix("/")
    path.include?("/") ? path : "layouts/#{path}"
  end

  def validate_template_path
    return if self.template_path.blank?
    lookup = ActionView::LookupContext.new(ActionController::Base.view_paths)
    unless lookup.exists?(File.basename(layout_path), [File.dirname(layout_path)])
      errors.add(:template_path, "is not a layout in this app (e.g. mailer or kapa/layouts/letter)")
    end
  end

  # Liquid errors are reported when saving, so a broken template can't reach a letter or an email.
  def validate_liquid
    {:body => self.body, :subject => self.subject}.each do |attribute, source|
      next if source.blank?
      Liquid::Template.parse(source, :error_mode => :strict)
    rescue Liquid::SyntaxError => e
      errors.add(attribute, "has a template error: #{e.message.sub(/\ALiquid syntax error: /, "")}")
    end
  end

  def to_html(options = {})
    locals = options[:locals] ? options[:locals] : {}
    locals[:dept] = self.dept if self.dept.present?
    html = Liquid::Template.parse(self.body, :error_mode => :strict).render(locals.stringify_keys).html_safe
    # The layout (template_path) is applied here for letters and emails alike, so this is the complete
    # HTML: the PDF source for letters, the message body for emails (Kapa::KapaMailerBase).
    if self.template_path.present?
      layout_renderer.render(:html => html, :layout => layout_path, :assigns => locals)
    else
      html
    end
  end

  def to_pdf(options = {})
    WickedPdf.new.pdf_from_string(self.to_html(options))
  end

  # For letters, the subject (Liquid) is the PDF file name, e.g. "Admission Letter {{ term_desc }}".
  # Returns nil when the letter has no subject.
  def pdf_file_name(locals = {})
    name = render_subject(locals).gsub(%r{[\\/:*?"<>|\r\n\t]+}, " ").squish.sub(/\.pdf\z/i, "")
    "#{name}.pdf" if name.present?
  end

  def to_file(options = {})
    @file = Kapa::File.new
    @file.name = pdf_file_name(options[:locals] || {}) || "#{self.title}.pdf"
    @file.data = StringIO.new(self.to_pdf(options))
    @file.data_file_name = @file.name
    @file.data_content_type = "application/pdf"
    return @file
  end
  
  class_methods do

    # Templates the app's code looks up, keyed by code: Rails.configuration.email_templates for emails
    # and Rails.configuration.letter_templates for letters (PDF). Codes are defined by developers; staff
    # pick one when creating a template. Each entry may have :title, :subject (emails), :variables
    # ({name => description}) and :sample (preview values). Apps without a registry get {}.
    def registry(type)
      name = type == "email" ? :email_templates : :letter_templates
      Rails.configuration.respond_to?(name) ? Rails.configuration.send(name) : {}
    end

    def email_registry
      registry("email")
    end

    # The active email template for a code, or nil.
    def email(code)
      emails.find_by(:code => code, :active => true)
    end

    # The active letter (PDF) template for a code, or nil.
    def letter(code)
      where(:code => code, :active => true).where("type IS NULL OR type <> 'email'").first
    end

    def selections(options = {})
      selections = []
      text_templates = Kapa::TextTemplate.where(:active => true).order("sequence DESC")
      text_templates = text_templates.where(options[:conditions]) if options[:conditions].present?
      text_templates.each { |v| selections.push [v.title, "0#{v.id}"] }
      return selections
    end

    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      text_templates = Kapa::TextTemplate.all
      text_templates = text_templates.where("active" => filter.active) if filter.active.present?
      return text_templates
    end
  end
end
