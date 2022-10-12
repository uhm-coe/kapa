module Kapa::TextTemplateBase
  extend ActiveSupport::Concern

  included do
    has_many :texts
  end

  def to_html(options = {})
    locals = options[:locals] ? options[:locals] : {}
    locals[:dept] = self.dept if self.dept.present?
    html = Liquid::Template.parse(self.body, :error_mode => :strict).render(locals.stringify_keys).html_safe
    if self.template_path.present?
      ApplicationController.render(:html => html, :layout => self.template_path, :assigns => locals)
    else
      html
    end
  end

  def to_pdf(options = {})
    WickedPdf.new.pdf_from_string(self.to_html(options))
  end

  def to_file(options = {})
    @file = Kapa::File.new
    @file.name = "#{self.title}.pdf"
    @file.data = StringIO.new(self.to_pdf(options))
    @file.data_file_name = @file.name
    @file.data_content_type = "application/pdf"
    return @file
  end
  
  class_methods do

    def selections(options = {})
      selections = []
      text_templates = Kapa::TextTemplate.where(:active => true).order("sequence DESC")
      text_templates = text_templates.where(options[:conditions]) if options[:conditions].present?
      text_templates.each { |v| selections.push [v.title, "0#{v.id}"] }
      return selections
    end

    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      text_templates = Kapa::TextTemplate.all
      text_templates = text_templates.where("active" => filter.active) if filter.active.present?
      return text_templates
    end
  end
end
