class ApplicationMailer < ActionMailer::Base
  default :from => Rails.configuration.mail_from
  
  def build(headers, options = {})
    logger.debug "---headers : #{headers.inspect}"
    @options = options
    mail(headers)
#    mail(:to => "test@withhawaii.com")
  end
end
