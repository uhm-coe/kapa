class Kapa::Cas

  def self.login_url(return_url)
    return "#{Rails.configuration.cas_host}#{Rails.configuration.cas_login_path}?service=#{return_url}"
  end

  def self.logout_url(return_url)
    return "#{Rails.configuration.cas_host}#{Rails.configuration.cas_logout_path}?service=#{return_url}"
  end

  def self.validate(ticket, return_url, options = {})
    cas_host = Rails.configuration.cas_host
    cas_validate_path = Rails.configuration.cas_validate_path
    uri = URI.parse(cas_host)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    body = http.start { |h| h.get("#{cas_validate_path}?service=#{return_url}&ticket=#{ticket}") }.body
    results = body.split(/\n/)

    if results[0] == "yes"
      uid = results[1]
      user = Kapa::User.where(:uid => uid, :category => "ldap").first
      if (user.nil?)
        person = Kapa::Person.lookup("#{uid}@hawaii.edu")
        if person.nil?
          logger.error "Invalid UH Email: #{uid}"
          return nil
        end
        person.save if person.new_record?
        user = person.users.where(:category => "ldap").first
        user = person.users.build(:uid => uid, :category => "ldap", :status => 10) if user.nil?
        user.uid = uid
        unless user.save
          logger.error "Failed to create the new ldap user: #{user.errors.inspect}"
          return nil
        end
      end

      return user
    else
      return nil
    end
  end

end