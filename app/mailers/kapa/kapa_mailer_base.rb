# Shared mailer behavior (included by Kapa::KapaMailer).
#
# App settings (all optional):
#   Rails.configuration.email_domain          domain for Message-IDs (default "localhost")
#   Rails.configuration.mail_enabled          false builds no mail, e.g. outside production (default true)
#   Rails.configuration.email_default_locals  Hash, or lambda returning one, merged into every
#                                             text-template email's variables (e.g. site URLs)
module Kapa::KapaMailerBase
  extend ActiveSupport::Concern

  included do
    # A lambda, so each email gets its own ID. (A plain string was evaluated once at load, giving every
    # email from a process the same Message-ID, so mail servers dropped all but one as duplicates.)
    default "Message-ID" => -> { "<#{SecureRandom.uuid}@#{Kapa::KapaMailerBase.email_domain}>" }
  end

  def self.email_domain
    Rails.configuration.respond_to?(:email_domain) ? Rails.configuration.email_domain : "localhost"
  end

  def mail_enabled?
    Rails.configuration.respond_to?(:mail_enabled) ? Rails.configuration.mail_enabled : true
  end

  # ERB email: options become instance variables for template_path/template_name in headers.
  # headers[:layout] wraps it in a layout, e.g. "mailer" (app/views/layouts/mailer); without one it has none.
  def build(headers, options = {})
    options.each_pair do |key, value|
      instance_variable_set("@#{key}", value)
    end
    return unless mail_enabled?
    headers = headers.dup
    layout = headers.delete(:layout)
    return mail(headers) unless layout
    mail(headers) do |format|
      format.html { render "#{headers[:template_path]}/#{headers[:template_name]}", :layout => layout }
    end
  end

  # Sends a staff-editable email: the active Kapa::Content with type "email" and this code
  # (managed in kapa under Letter/E-mail Templates). The subject and body are Liquid, rendered with
  # locals plus Rails.configuration.email_default_locals. Content#to_html returns the complete
  # HTML with the template's layout (template_path); a template without one is sent plain.
  # Without a template nothing is sent.
  def build_from_content(code, headers, locals, subject_prefix: nil)
    return unless mail_enabled?
    template = Kapa::Content.email(code)
    unless template
      Rails.logger.error "Email template '#{code}' is missing or inactive; email not sent."
      return
    end

    locals = default_email_locals.deep_stringify_keys.merge(locals.deep_stringify_keys)
    mail(headers.merge(:subject => "#{subject_prefix}#{template.render_subject(locals)}")) do |format|
      format.html { render :html => template.to_html(:locals => locals), :layout => false }
    end
  end

  private

  def default_email_locals
    defaults = Rails.configuration.respond_to?(:email_default_locals) ? Rails.configuration.email_default_locals : {}
    (defaults.respond_to?(:call) ? defaults.call : defaults) || {}
  end
end
