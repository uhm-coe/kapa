module Kapa::FormTemplateBase
  extend ActiveSupport::Concern

  included do
    serialize :dept, Kapa::CsvSerializer
    serialize :course, Kapa::CsvSerializer
    serialize :program, Kapa::CsvSerializer
    serialize :transition_point, Kapa::CsvSerializer
    has_many :form_fields, -> {order("form_fields.criterion")}, :dependent => :destroy
    validates_presence_of :title
  end

  def effective_term
    "#{Kapa::Term.find(self.start_term_id).description} - #{Kapa::Term.find(self.end_term_id).description}" if self.start_term_id.present? and self.end_term_id.present?
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
