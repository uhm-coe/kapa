#Location of storing attachment files
Paperclip::Attachment.default_options[:path] = "/tmp/class/:id_partition/:style.:extension"

#Mailer setting
Rails.configuration.mail_from = "admin@localhost"

#Location of your public key to encrypt database fields.
Rails.configuration.public_key = "#{Rails.root}/config/kapa.pub"

#Regular expression for campus ID and email.
Rails.configuration.regex_id_number = '[\d]{8}'
Rails.configuration.regex_email = '^[A-Z0-9_%+-]+@hawaii.edu$'
