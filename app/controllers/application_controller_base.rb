module ApplicationControllerBase
  extend ActiveSupport::Concern
  
  included do
    protect_from_forgery
    helper :all
    helper_method :beta?
  end

  def error_404
    unless request.path =~ /^\/apple-touch-icon/
      logger.error "*404* #{request.method} #{request.path} from #{request.remote_ip} #{Kapa::UserSession.find.try(:user).try(:uid)}"
    end
    render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found
  end

  # def default_url_options(options={})
  #   if Rails.env.production?
  #     options.merge(:protocol => "https")
  #   else
  #     options
  #   end
  # end

  private
  def error_message_for(*args)
    options = args.last.is_a?(Hash) ? args.last : {}
    errors = []
    args.each { |a| errors << a.errors.full_messages.join(", ") if a.is_a?(ActiveRecord::Base) and not a.errors.blank? }
    message = errors.join(", ")
    options[:sub].each_pair { |pattern, replacement| message.gsub!(pattern, replacement) } if options[:sub]
    return message
  end

  def beta?
    Rails.application.secrets.release != "live"
  end
end
