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
    category.to_s.strip!
    label.to_s.strip!
    label_desc.to_s.strip!
    label_desc.to_s.sub!("\n", "")
  end

end
