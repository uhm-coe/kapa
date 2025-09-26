module Kapa::ContentBase
  extend ActiveSupport::Concern

  included do
    validates_presence_of :page, :region
  end
  
  def to_html(variables  = {})
    Liquid::Template.parse(self.html, :error_mode => :strict).render(variables).html_safe
  end
  
  class_methods do
    
    def contents_for(page)
      contents = OpenStruct.new
      Kapa::Content.where(:page => page).each do |c|
        contents[c.region] = c
      end
      return contents
    end

    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      contents = Kapa::Content.all.order(:page, :region)
      contents = contents.where(:page => filter.page)  if filter.page.present?
      return contents
    end

  end

end
