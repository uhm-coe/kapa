module ApplicationControllerBase
  extend ActiveSupport::Concern
  
  included do
    protect_from_forgery with: :exception
    rescue_from StandardError, with: :error_500    
    helper :all
  end

  def error_404
    unless request.path =~ /^\/apple-touch-icon/
      logger.error "The page doesn't exist. #{Kapa::UserSession.find.try(:user).try(:uid)}"
    end
    render :template => "errors/404", :layout => false, :status => :not_found
  end

  def error_500(exception)
    if Rails.env.production?
      @error_id = SecureRandom.hex(4)
      logger.error "[#{@error_id}] #{exception.class}: #{exception.message}\n#{exception.backtrace.join("\n")}"
      render :template => "errors/500", :layout => false, :status => :internal_server_error
    else
      raise exception
    end
  end

  private
  def error_message_for(*args)
    options = args.last.is_a?(Hash) ? args.last : {}
    errors = []
    args.each { |a| errors << a.errors.full_messages.join(", ") if a.is_a?(ActiveRecord::Base) and not a.errors.blank? }
    message = errors.join(", ")
    options[:sub].each_pair { |pattern, replacement| message.gsub!(pattern, replacement) } if options[:sub]
    return message
  end
end
