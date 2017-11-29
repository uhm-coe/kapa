module Kapa::FormTemplateBase
  extend ActiveSupport::Concern

  included do
    has_many :form_fields, -> {order("form_fields.label")}, :dependent => :destroy
    validates_presence_of :title, :type
  end

  def effective_term
    "#{Kapa::Property.lookup_description(:term, self.start_term)} - #{Kapa::Property.lookup_description(:term, self.end_term)}" if self.start_term.present? and self.end_term.present?
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      form_templates = Kapa::FormTemplate.eager_load([:form_fields]).order("dept, title")
      form_templates = form_templates.column_matches(:title => filter.title) if filter.title.present?
      form_templates = form_templates.column_contains(:program => filter.program) if filter.program.present?
      form_templates = form_templates.column_contains(:course => filter.course) if filter.course.present?
      form_templates = form_templates.column_contains(:transition_point => filter.transition_point) if filter.transition_point.present?
      return form_templates
    end
  end
end
