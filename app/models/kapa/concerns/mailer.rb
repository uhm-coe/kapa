module Kapa::Concerns::Mailer
  extend ActiveSupport::Concern

  def message(recipients, options = {})
    @from = options[:from] ||= Rails.configuration.mail_from
    @recipients = recipients
    @subject = options[:subject]
    @body = options[:body]
    @content_type = "text/html"
    @template = options[:template]
  end
end
