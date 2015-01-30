
#Location of storing database files
Paperclip::Attachment.default_options[:path] = "/tmp/class/:id_partition/:style.:extension"

#Mailer setting
Rails.configuration.mail_from = "admin@localhost"

#Location of your public key to encrypt database fields.
Rails.configuration.public_key = "#{Rails.root}/config/kapa.pub"
