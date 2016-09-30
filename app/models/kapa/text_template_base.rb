module Kapa::TextTemplateBase
  extend ActiveSupport::Concern

  included do
    has_many :texts

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
