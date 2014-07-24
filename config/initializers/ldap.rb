Kapa::Application.config.ldap = Net::LDAP.new(:host => AppConfig.ldap_host,
                                             :port => AppConfig.ldap_port,
                                             :auth => {:method => :simple, :username => AppConfig.ldap_username, :password => AppConfig.ldap_password},
                                             :encryption => :start_tls)
