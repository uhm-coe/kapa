module Kapa::FormTemplateFieldBase
  extend ActiveSupport::Concern

  included do
    belongs_to :form_template
    has_many :form_fields
    validates_uniqueness_of :label, :scope => :form_template_id
    validates_presence_of :label
    before_save :format_fields
  end

  def format_fields
    label.to_s.strip!
    hint.to_s.sub!("\n", "")
    name = label.underscore #if name.blank?
  end
end
