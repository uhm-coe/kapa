module Kapa::MessageBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    belongs_to :bulk_message
    belongs_to :message_template
    belongs_to :attachable, :polymorphic => true

    validates_presence_of :person_id
    after_create :set_default_contents, :replace_variables
  end

  def send_message!
    self.delivered_at = DateTime.now
    self.save!
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
