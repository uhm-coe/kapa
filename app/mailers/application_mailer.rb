class ApplicationMailer < ActionMailer::Base
  default :from => AppConfig.mail_from
  
  def build(headers, options = {})
    logger.debug "---headers : #{headers.inspect}"
    @options = options
    mail(headers)
#    mail(:to => "test@withhawaii.com")
  end
end
