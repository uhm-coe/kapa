class Mailer < ActionMailer::Base

  def message(recipients, options = {})
    @from = options[:from] ||= AppConfig.mail_from
    @recipients = recipients
    @subject = options[:subject]
    @body = options[:body]
    @content_type = "text/html"
    @template = options[:template]
  end

end
