module Kapa::ContentBase
  extend ActiveSupport::Concern

  included do
    has_many :texts
    # Email templates (type "email") are rendered by the app's mailer; other types are PDF letters.
    scope :emails, -> { where(:type => "email") }
    scope :letters, -> { where("type IS NULL OR type <> 'email'") }
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

    # Contents the app's code looks up, by type ("email", "letter") and code: Rails.configuration.contents,
    # loaded by the app from config/content.yml. A blank type is a letter. Codes are defined by developers;
    # staff pick one when creating a template. Each entry may have :title, :subject, :template_path,
    # :variables ({name => description}) and :sample (preview values). Apps without a registry get {}.
    def registry(type)
      contents = Rails.configuration.respond_to?(:contents) ? Rails.configuration.contents : {}
      contents[type.presence || "letter"] || {}
    end

    # Creates the default template for each registered code of this type that has none yet (templates
    # staff already edited are left alone). The body is read from db/<type>_templates/<code>.liquid;
    # title, subject and template_path come from the registry entry. Returns the created templates.
    def create_missing_defaults!(type, codes = nil)
      entries = registry(type)
      entries = entries.slice(*codes) if codes
      entries.filter_map do |code, config|
        next if Kapa::Content.exists?(:code => code)
        body = Rails.root.join("db/#{type}_templates/#{code}.liquid")
        Kapa::Content.create!(:type => type, :code => code, :title => config[:title], :subject => config[:subject],
                              :template_path => config[:template_path], :body => (body.exist? ? body.read : ""),
                              :active => true)
      end
    end

    # The active email template for a code, or nil.
    def email(code)
      emails.find_by(:code => code, :active => true)
    end

    # The active letter (PDF) template for a code, or nil.
    def letter(code)
      letters.find_by(:code => code, :active => true)
    end

    def selections(options = {})
      selections = []
      contents = Kapa::Content.where(:active => true).order("sequence DESC")
      contents = contents.where(options[:conditions]) if options[:conditions].present?
      contents.each { |v| selections.push [v.title, "0#{v.id}"] }
      return selections
    end

    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      contents = Kapa::Content.all
      contents = contents.where("active" => filter.active) if filter.active.present?
      return contents
    end
  end
end
