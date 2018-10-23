module Kapa::FormTemplateBase
  extend ActiveSupport::Concern

  included do
    has_many :form_template_fields, -> {order("form_template_fields.sequence, form_template_fields.label")}, :dependent => :destroy
    validates_presence_of :title, :type
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      form_templates = Kapa::FormTemplate.eager_load([:form_template_fields]).order("dept, title")
      form_templates = form_templates.column_matches(:title => filter.title) if filter.title.present?
      return form_templates
    end
  end
end
