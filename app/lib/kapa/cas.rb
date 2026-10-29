require 'net/http'

# CAS 1.0 client shared by the admin and student sites. Configure with
# Rails.configuration.cas_host, cas_login_path, cas_validate_path and cas_logout_path.
module Kapa::Cas
  TIMEOUT = 10

  def self.defined?
    Rails.configuration.respond_to?(:cas_host)
  end

  def self.login_url(service)
    url(Rails.configuration.cas_login_path, :service => service)
  end

  def self.logout_url(service)
    url(Rails.configuration.cas_logout_path, :service => service)
  end

  # Returns the uid the ticket was issued to, or nil when the ticket is invalid or CAS cannot be reached.
  def self.authenticate(ticket, service)
    results = validate(ticket, service)
    return results[1] if results[0] == "yes" and results[1].present?
    # CAS 1.0 gives no reason; usually a reused or expired (10 seconds) ticket, or a service URL that differs from the registered one.
    Rails.logger.error "*ERROR* CAS rejected the ticket for service #{service}" if results[0] == "no"
    nil
  end

  # Returns the CAS response lines, e.g. ["yes", "uid"] or ["no"]; [] when the server cannot be reached.
  def self.validate(ticket, service)
    return [] if ticket.blank?
    response = request(url(Rails.configuration.cas_validate_path, :service => service, :ticket => ticket))
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error "*ERROR* CAS validation returned HTTP #{response.code}"
      return []
    end
    response.body.to_s.lines.map(&:strip)
  rescue StandardError => e
    Rails.logger.error "*ERROR* CAS validation failed: #{e.class}: #{e.message}"
    []
  end

  # Net::HTTP verifies the server certificate (VERIFY_PEER) by default; do not turn that off,
  # or anyone between this server and CAS could answer "yes" for any uid.
  def self.request(url)
    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == "https",
                    :open_timeout => TIMEOUT, :read_timeout => TIMEOUT) do |http|
      http.get(uri.request_uri)
    end
  end

  def self.url(path, params)
    "#{Rails.configuration.cas_host}#{path}?#{URI.encode_www_form(params)}"
  end
  private_class_method :url
end
