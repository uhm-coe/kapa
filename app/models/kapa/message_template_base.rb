module Kapa::MessageTemplateBase
  extend ActiveSupport::Concern

  included do
    has_many :bulk_messages
    has_many :messages
  end

  class_methods do

    def selections(options = {})
      selections = []
      message_templates = Kapa::MessageTemplate.where(:active => true).order("sequence DESC")
      message_templates = message_templates.where(options[:conditions]) if options[:conditions].present?
      message_templates.each { |v| selections.push [v.title, "0#{v.id}"] }
      return selections
    end

    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      message_templates = Kapa::MessageTemplate.all
      message_templates = message_templates.where("active" => filter.active) if filter.active.present?
      return message_templates
    end
  end
end
