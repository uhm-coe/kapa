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

  # This content as a db/contents/<type>/<code>.liquid file: YAML front matter, then the body.
  # default_attributes reads it back.
  def to_default_file
    front_matter = {"subject" => self.subject.to_s.to_json}
    front_matter["template_path"] = default_file_value(self.template_path) if self.template_path.present?
    front_matter["dept"] = default_file_value(self.dept) if self.dept.present?
    front_matter["active"] = self.active ? "true" : "false"
    "---\n#{front_matter.map { |name, value| "#{name}: #{value}" }.join("\n")}\n---\n#{self.body}"
  end

  # Plain words and paths (student_mail, kapa/layouts/letter, OSAS) stay unquoted, as in the hand-written
  # files; anything YAML could read as another type (yes, null, 123, "- x") is quoted.
  def default_file_value(value)
    value = value.to_s
    plain = value.match?(%r{\A[A-Za-z][\w/.\-]*\z}) && !value.match?(/\A(true|false|yes|no|on|off|null|y|n)\z/i)
    plain ? value : value.to_json
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
    # the rest from db/contents/<type>/<code>.liquid, which starts with YAML front matter:
    #   ---
    #   subject: "Your application was submitted"
    #   template_path: student_mail
    #   dept: OSAS
    #   active: true
    #   ---
    #   <p>Dear {{ student_name | escape }},</p>
    def default_attributes(type, code)
      path = Rails.root.join("db/contents/#{type}/#{code}.liquid")
      {:type => type, :code => code, :title => registry(type).dig(code, :title), :active => true}
        .merge(parse_default_file(path.exist? ? path.read : ""))
    end

    # The subject, template_path, dept and active in a default file's front matter (those present),
    # and the body after it.
    def parse_default_file(source)
      front_matter, body = {}, source
      if (match = source.match(/\A---[ \t]*\n(.*?)\n---[ \t]*(?:\n|\z)/m))
        front_matter, body = (YAML.safe_load(match[1]) || {}), match.post_match
      end
      front_matter.slice("subject", "template_path", "dept", "active").transform_keys(&:to_sym).merge(:body => body)
    end

    # Creates the default template for each registered code that has none yet (templates staff already
    # edited are left alone), for one type or, without a type, every registered type, from
    # default_attributes. Returns the created templates.
    def create_missing_defaults!(type = nil, codes = nil)
      (type ? [type] : registry_types).flat_map do |t|
        codes_of_type = registry(t).keys
        codes_of_type &= codes if codes
        existing = Kapa::Content.where(:code => codes_of_type).pluck(:code)
        (codes_of_type - existing).map { |code| Kapa::Content.create!(default_attributes(t, code)) }
      end
    end

    # Every content with a code, as a zip of db/contents files (contents/<type>/<code>.liquid), so the
    # contents in one database (e.g. production) can be copied into a checkout's db/ folder.
    def to_zip
      Zip::OutputStream.write_buffer do |zip|
        Kapa::Content.where.not(:code => [nil, ""]).where(:type => %w(email pdf)).order(:type, :code).each do |content|
          zip.put_next_entry("contents/#{content.type}/#{content.code}.liquid")
          zip.write(content.to_default_file)
        end
      end.string
    end

    # Overwrites each registered content with its db/contents file, creating it if missing (rake
    # kapa:contents:load), e.g. after unzipping contents downloaded from production. Unlike
    # create_missing_defaults!, staff edits are replaced. Returns {code => :created, :updated or :unchanged}.
    def load_defaults!(codes = nil)
      registry_types.each_with_object({}) do |type, results|
        codes_of_type = registry(type).keys
        codes_of_type &= codes if codes
        codes_of_type.each do |code|
          content = Kapa::Content.find_or_initialize_by(:code => code)
          status = content.new_record? ? :created : :updated
          content.assign_attributes(default_attributes(type, code))
          status = :unchanged unless content.changed?
          content.save!
          results[code] = status
        end
      end
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
