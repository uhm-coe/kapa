module Kapa::BulkMessageBase
  extend ActiveSupport::Concern

  included do
    has_many :messages
    belongs_to :message_template

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

  def send_messages
    person_ids = Kapa::ContactList.where(:id => self.ext.contact_list_ids).map(&:person_ids) + self.ext.person_ids
    persons = Kapa::Person.where(:id => person_ids.flatten.uniq)
    persons.each do |person|
      message = person.messages.build(self.attributes.slice("name", "subject", "body", "message_template_id"))
      message.bulk_message = self
      message.save
    end
  end
end
