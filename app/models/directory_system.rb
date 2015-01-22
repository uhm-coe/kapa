class DirectorySystem

  def self.is_defined?
    true
  end

  def self.person(type, key)

    persons = []
    filter = Rails.configuration.send(type).gsub("?", key)
    Rails.configuration.ldap.search(:base => Rails.configuration.ldap_search_base, :filter => filter ) do |entry|
      person = Person.new
      entry.each do |attribute, values|
        case attribute.to_s
          when Rails.configuration.ldap_attr_id_number
            person.id_number = values.first.to_s
          when Rails.configuration.ldap_attr_last_name
            person.last_name = values.first.to_s
          when Rails.configuration.ldap_attr_first_name
            person.first_name = values.first.to_s
          when Rails.configuration.ldap_attr_mail
            person.email = values.first.to_s
        end
      end
      person.source = "LDAP"
      person.status = "V"
      persons.push(person)
    end if filter

    return persons.first
  end

  def self.authenticate(uid, password)
    ldap = Rails.configuration.ldap
    base = Rails.configuration.ldap_search_base
    filter = "#{Rails.configuration.ldap_attr_uid}=#{uid}"
    dn = nil
    ldap.search(:base => base, :filter => filter) do |entry|
      dn = entry.dn
    end
    return false if dn.nil?

    result = ldap.bind(:method => :simple, :dn => dn , :password => password)
    return result
  end

end