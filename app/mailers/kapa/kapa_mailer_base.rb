# Shared mailer behavior. Include in the app's mailers (e.g. UserMailer).
module Kapa::KapaMailerBase
  extend ActiveSupport::Concern

  # Sends a staff-editable email: the active Kapa::TextTemplate with type "email" and this code
  # (managed in kapa under Templates). The subject and body are Liquid, rendered with locals, and the
  # body is wrapped in the template's layout (template_path), or the given layout when it has none.
  # Without a template nothing is sent.
  def build_from_text_template(code, headers, locals, subject_prefix: nil, layout: "mailer")
    template = Kapa::TextTemplate.email(code)
    unless template
      Rails.logger.error "Email template '#{code}' is missing or inactive; email not sent."
      return
    end

    locals = locals.deep_stringify_keys
    mail(headers.merge(:subject => "#{subject_prefix}#{template.render_subject(locals)}")) do |format|
      format.html { render :html => template.to_html(:locals => locals), :layout => template.layout_path || layout }
    end
  end
end
