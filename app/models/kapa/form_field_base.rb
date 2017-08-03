module Kapa::FormFieldBase
  extend ActiveSupport::Concern

  included do
    belongs_to :form_template
    has_many :form_details
    validates_uniqueness_of :criterion, :scope => :form_template_id
    validates_presence_of :criterion
    before_save :format_fields
  end

  def format_fields
    standard.to_s.strip!
    criterion.to_s.strip!
    criterion_desc.to_s.strip!
    criterion_desc.to_s.sub!("\n", "")
  end

  def criterion_detail
    criterion_html
  end
end
