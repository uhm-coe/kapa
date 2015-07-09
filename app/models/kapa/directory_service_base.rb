module Kapa::DirectoryServiceBase
  extend ActiveSupport::Concern

  module ClassMethods
    def is_defined?
      Rails.configuration.ldap.present?
    end

    def authenticate(uid, password)
      ldap = Rails.configuration.ldap
      base = Rails.configuration.ldap_search_base
      filter = Net::LDAP::Filter.eq(Rails.configuration.ldap_uid_filter, uid)
      filter = filter & Rails.configuration.ldap_default_filter_auth if Rails.configuration.ldap_default_filter_auth
      dn = nil
      ldap.search(:base => base, :filter => filter) do |entry|
        dn = entry.dn
      end
      return false if dn.nil?

      result = ldap.bind(:method => :simple, :dn => dn, :password => password)
      return result
    end

    def person(key)
      self.persons(key).first
    end

    def persons(key)
      Rails.logger.debug("Searching LDAP...  Key: #{key}")
      case key
        when Regexp.new(Rails.configuration.regex_id_number, true)
          filter = Net::LDAP::Filter.eq(Rails.configuration.ldap_attr_id_number, key)
        when Regexp.new(Rails.configuration.regex_email, true)
          filter = Net::LDAP::Filter.eq(Rails.configuration.ldap_attr_email, key)
        else
          filter = nil
      end
      filter = filter & Rails.configuration.ldap_default_filter_persons if Rails.configuration.ldap_default_filter_persons
      persons = Array.new
      Rails.application.config.ldap.search(:base => Rails.configuration.ldap_search_base, :filter => filter) do |entry|
        person = Kapa::Person.new
        entry.each do |attribute, values|
          case attribute.to_s
            when Rails.configuration.ldap_attr_id_number
              person.id_number = values.first.to_s
            when Rails.configuration.ldap_attr_last_name
              person.last_name = values.first.to_s
            when Rails.configuration.ldap_attr_first_name
              person.first_name = values.first.to_s
            when Rails.configuration.ldap_attr_email
              person.email = values.first.to_s
          end
        end
        person.source = self.source
        person.status = "V"
        persons.push(person)
      end if filter

      return persons
    end

    def source
      "LDAP"
    end
  end # included
end
