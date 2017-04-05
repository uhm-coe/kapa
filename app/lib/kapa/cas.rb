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
    end
    body = http.get("#{cas_validate_path}?service=#{return_url}&ticket=#{ticket}").body
    return body.split(/\n/)
  end

end