module Kapa::FormTemplateFieldBase
  extend ActiveSupport::Concern

  included do
    belongs_to :form_template
    has_many :form_fields
    validates_uniqueness_of :name, :scope => :form_template_id
    validates_presence_of :label
    before_save :format_fields
    self.serialize_field = :json
  end

  def format_fields
    self.label.to_s.strip!
    self.hint.to_s.sub!("\n", "")
    self.name = self.label.underscore if self.name.blank?
  end
end
