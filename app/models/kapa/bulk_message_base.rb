module Kapa::BulkMessageBase
  extend ActiveSupport::Concern

  included do
    has_many :messages

    after_create :set_default_contents, :replace_variables
  end

  def set_default_contents
    if self.message_template.present?
      self.name = self.message_template.title
      self.body = self.message_template.body
      self.save
    end
  end

  def replace_variables
  end
end
