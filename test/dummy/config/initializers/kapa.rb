
#Location of storing database files
Paperclip::Attachment.default_options[:path] = "/tmp/class/:id_partition/:style.:extension"

Dummy::Application.config.mail_from = "admin@localhost"

#Location of your public to encrypt database fields.
Dummy::Application.config.public_key = "#{Rails.root}/config/kapa.pub"

#Connection information for LDAP
Dummy::Application.config.ldap = Net::LDAP.new(:host => "", :port => "", :encryption => :start_tls,
                                                             :auth => {:method => :simple, :username => "", :password => ""})
Dummy::Application.config.ldap_search_base = "ou=People,dc=hawaii,dc=edu"
Dummy::Application.config.ldap_uid_filter = ""
Dummy::Application.config.ldap_id_number_filter = ""
Dummy::Application.config.ldap_mail_filter = ""
Dummy::Application.config.ldap_attr_id_number = "uhuuid"
Dummy::Application.config.ldap_attr_uid = "uid"
Dummy::Application.config.ldap_attr_last_name = "sn"
Dummy::Application.config.ldap_attr_first_name = "givenname"
Dummy::Application.config.ldap_attr_email = "mail"
