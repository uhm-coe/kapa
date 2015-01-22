

#Location of storing database files
Paperclip::Attachment.default_options[:path] = "/tmp/class/:id_partition/:style.:extension"

#Location of your public to encrypt database fields.
Dummy::Application.config.public_key = "#{Rails.root}/config/kapa.pub"

#Connection information for LDAP