module Kapa::ContentBase
  extend ActiveSupport::Concern

  included do
    has_many :texts
    # Types: "email" (rendered by the app's mailer) and "pdf" (letters and other generated documents).
    scope :emails, -> { where(:type => "email") }
    scope :pdfs, -> { where(:type => "pdf") }
    validates_inclusion_of :type, :in => %w(email pdf)
    validates_presence_of :code, :subject, :if => :email?
    validates_uniqueness_of :code, :allow_blank => true
    validate :validate_liquid
    validate :validate_template_path
  end

  def email?
    self.type == "email"
  end

  def pdf?
    self.type == "pdf"
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

  # template_path is a layout: "student_mail" (app/views/layouts/student_mail) or a full path such as "kapa/layouts/letter".
  def layout_path
    return nil if self.template_path.blank?
    path = self.template_path.delete_prefix("/")
    path.include?("/") ? path : "layouts/#{path}"
  end

  def validate_template_path
    return if self.template_path.blank?
    lookup = ActionView::LookupContext.new(ActionController::Base.view_paths)
    unless lookup.exists?(File.basename(layout_path), [File.dirname(layout_path)])
      errors.add(:template_path, "is not a layout in this app (e.g. student_mail or kapa/layouts/letter)")
    end
  end

  # Liquid errors are reported when saving, so a broken template can't reach a PDF or an email.
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
    # The layout (template_path) is applied here for PDFs and emails alike, so this is the complete
    # HTML: the PDF source for PDFs, the message body for emails (Kapa::KapaMailerBase).
    if self.template_path.present?
      layout_renderer.render(:html => html, :layout => layout_path, :assigns => locals)
    else
      html
    end
  end

  def to_pdf(options = {})
    WickedPdf.new.pdf_from_string(self.to_html(options))
  end

  # For PDFs, the subject (Liquid) is the file name, e.g. "Admission Letter {{ term_desc }}".
  # Returns nil when the template has no subject.
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

    # Contents the app's code looks up, by type ("email", "pdf") and code: Rails.configuration.contents,
    # loaded by the app from config/content.yml. Codes are defined by developers, and only registered
    # contents exist (create_missing_defaults!). Each entry has :title (the internal name, which staff
    # can't change), :variables ({name => description}) and :sample (preview values). Apps without a
    # registry get {}.
    def registry(type)
      contents = Rails.configuration.respond_to?(:contents) ? Rails.configuration.contents : {}
      contents[type.to_s] || {}
    end

    def registry_types
      Rails.configuration.respond_to?(:contents) ? Rails.configuration.contents.keys : []
    end

    # The attributes a registered content is created with: type, code and title from the registry, and
    # subject, body, template_path, dept and active from its row (labeled by code) in
    # db/fixtures/contents.yml (rake kapa:contents:dump). Without a row, it is created active and empty.
    # Pass fixtures (default_fixtures) when looking up several codes, so the file is read once.
    def default_attributes(type, code, fixtures = default_fixtures)
      row = (fixtures[code] || {}).slice("subject", "body", "template_path", "dept", "active")
      {:type => type, :code => code, :title => registry(type).dig(code, :title), :active => true}
        .merge(row.transform_keys(&:to_sym))
    end

    # The rows of db/fixtures/contents.yml, read like Rails fixtures (ERB, then YAML), or {}.
    def default_fixtures
      path = Rails.root.join("db/fixtures/contents.yml")
      path.exist? ? (YAML.safe_load(ERB.new(path.read).result) || {}) : {}
    end

    # Creates the default template for each registered code that has none yet (templates staff already
    # edited are left alone), for one type or, without a type, every registered type, from
    # default_attributes. Used when the app boots, so a code added to the registry reaches production.
    # (Seeds and rake kapa:contents:load replace the whole table from the fixture instead.)
    # Returns the created templates.
    def create_missing_defaults!(type = nil, codes = nil)
      fixtures = nil
      (type ? [type] : registry_types).flat_map do |t|
        codes_of_type = registry(t).keys
        codes_of_type &= codes if codes
        existing = Kapa::Content.where(:code => codes_of_type).pluck(:code)
        (codes_of_type - existing).map do |code|
          fixtures ||= default_fixtures
          Kapa::Content.create!(default_attributes(t, code, fixtures))
        end
      end
    end

    # All contents as a Rails fixture file (rake kapa:contents:dump and the admin's Download), labeled by code. Psych quotes values
    # YAML would misread, such as a subject starting with Liquid's "{{" or "{%". Fixture files also run
    # through ERB before YAML, so "<%" in a value is written as "<%%" (Liquid tags aren't ERB).
    # The serialized yml column is written as stored, not as a Ruby hash. The json column isn't used.
    def to_fixtures
      fixtures = Kapa::Content.order(:type, :code, :id).each_with_object({}) do |content, rows|
        rows[content.code.presence || "content_#{content.id}"] = content.attributes.except("json").to_h do |name, value|
          value = content.read_attribute_before_type_cast(name) if value.is_a?(Hash) || value.is_a?(Array)
          value = value.utc.to_fs(:db) if value.is_a?(Time)
          value = value.gsub("<%", "<%%") if value.is_a?(String)
          [name, value]
        end
      end
      fixtures.to_yaml(:line_width => -1)
    end

    # Titles are defined in the registry; copies a changed title to its record. Returns the number updated.
    def sync_titles!
      registry_types.sum do |t|
        registry(t).sum do |code, config|
          next 0 if config[:title].blank?
          Kapa::Content.where(:code => code).where("title IS NULL OR title <> ?", config[:title]).update_all(:title => config[:title])
        end
      end
    end

    # Run when the app boots (config.after_initialize), so a code added to the registry gets its default
    # and a renamed title reaches its record. Skipped while the database isn't ready: no database (e.g.
    # assets precompile) or pending migrations (e.g. db:migrate, which boots the app before migrating).
    def create_missing_defaults_on_boot!
      return if ActiveRecord::Base.connection_pool.migration_context.needs_migration?
      created = create_missing_defaults!
      sync_titles!
      Rails.logger.info "Created default contents: #{created.map(&:code).join(", ")}" if created.any?
    rescue ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished => e
      Rails.logger.warn "Default contents not created (database not ready): #{e.message}"
    rescue ActiveRecord::RecordNotUnique
      # Another process booting at the same time created it.
    end

    # The active email template for a code, or nil.
    def email(code)
      emails.find_by(:code => code, :active => true)
    end

    # The active PDF template for a code, or nil.
    def pdf(code)
      pdfs.find_by(:code => code, :active => true)
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
