module Kapa::ContactBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
  end

  def format
    self.attributes().each_pair do |k, v|
      if v
        self.[]=(k, v.gsub(/\D/, "")) if k =~ /(phone$)/
        self.[]=(k, v.to_s.split(' ').map { |w| w.capitalize }.join(' ')) if k =~ /(street$)|(city$)/
        self.[]=(k, v.to_s.upcase) if k =~ /(state$)/
      end
    end
  end

  def email_alt
    email unless email =~ /^[A-Z0-9_%+-]+@hawaii.edu$/i
  end

  def cur_address
    "#{cur_street}<br/>#{cur_city}, #{cur_state} #{cur_postal_code}".html_safe
  end

  def per_address
    "#{per_street}<br/>#{per_city}, #{per_state} #{per_postal_code}".html_safe
  end

end
