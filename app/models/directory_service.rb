class DirectoryService

  def self.is_defined?
    Rails.configuration.ldap.present?
  end

  def self.authenticate(uid, password)
    ldap = Rails.configuration.ldap
    base = Rails.configuration.ldap_search_base
    filter = Rails.configuration.ldap_uid_filter.gsub("?", uid)
    dn = nil
    ldap.search(:base => base, :filter => filter) do |entry|
      dn = entry.dn
    end
    return false if dn.nil?

    result = ldap.bind(:method => :simple, :dn => dn , :password => password)
    return result
  end

  def self.person(key)
    self.persons(key).first
  end

  def self.persons(key)

    case key
    when /[\d]{8}/
      filter = "#{AppConfig.ldap_attr_id_number}=#{key}"
    when /^[A-Z0-9_%+-]+@hawaii.edu$/i
      filter = "#{AppConfig.ldap_attr_email}=#{key}"
    else
      filter = nil
    end

    persons = Array.new
    Rails.application.config.ldap.search(:base => AppConfig.ldap_search_base, :filter => filter ) do |entry|
      person = Person.new
      logger.debug "----LDAP search entry #{entry.dn}"
      entry.each do |attribute, values|
        case attribute.to_s
          when AppConfig.ldap_attr_id_number
            person.id_number = values.first.to_s
          when AppConfig.ldap_attr_last_name
            person.last_name = values.first.to_s
          when AppConfig.ldap_attr_first_name
            person.first_name = values.first.to_s
          when AppConfig.ldap_attr_email
            person.email = values.first.to_s
        end
      end
      person.source = "UH LDAP"
      person.status = "V"
      persons.push(person)
    end if filter

    return persons
  end
end