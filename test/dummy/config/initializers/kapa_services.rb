# Be sure to restart your server when you modify this file.

# Default LDAP configuration used for user authentication
#Rails.configuration.ldap_base = "ou=people,dc=hawaii,dc=edu"
#Rails.configuration.ldap_filter = "(uid = ?)"
#Rails.configuration.ldap_settings ={
#  :host => "ldap.hawaii.edu",
#  :port => 389,
#  :encryption => {:method => :simple},
#  :auth => {:username => Rails.application.credentials.ldap_uh_username,
#            :password =>  Rails.application.credentials.ldap_uh_password}
#}

# CAS configuration
# Rails.configuration.cas_host = Rails.env.production? ? "https://authn.hawaii.edu" : "https://cas-test.its.hawaii.edu"
# Rails.configuration.cas_login_path = "/cas/login"
# Rails.configuration.cas_validate_path =  "/cas/validate"
# Rails.configuration.cas_logout_path = "/cas/logout"

# Action Mailer configuration
#Rails.configuration.action_mailer.default_options = {from: "sishelp@hawaii.edu"}
#Rails.configuration.action_mailer.raise_delivery_errors = true
#Rails.configuration.action_mailer.perform_deliveries = true
#Rails.configuration.action_mailer.delivery_method = :smtp
#Rails.configuration.action_mailer.smtp_settings = {
#  :address => "smtp.gmail.com",
#  :port => 587,
#  :domain => "hawaii.edu",
#  :user_name => Rails.application.credentials.mail_sishelp_username,
#  :password => Rails.application.credentials.mail_sishelp_password,
#  :authentication => :login,
#  :enable_starttls_auto => true
#}
