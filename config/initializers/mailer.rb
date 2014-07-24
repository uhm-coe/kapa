#Action Mailer configuration
Kapa::Application.config.action_mailer.delivery_method = :sendmail
#Kapa::Application.config.action_mailer.smtp_settings = {:address => AppConfig.smtp_address, :port => AppConfig.smtp_port}
Kapa::Application.config.action_mailer.raise_delivery_errors = true
Kapa::Application.config.action_mailer.perform_deliveries = true
