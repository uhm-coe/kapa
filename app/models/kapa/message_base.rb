module Kapa::MessageBase
  extend ActiveSupport::Concern

  included do
    belongs_to :messageable, :polymorphic => true
    serialize :to, :coder => Kapa::CsvSerializer
    serialize :from, :coder => Kapa::CsvSerializer
    serialize :cc, :coder => Kapa::CsvSerializer
    serialize :bcc, :coder => Kapa::CsvSerializer
    serialize :reply_to, :coder => Kapa::CsvSerializer
  end

  def date
    self.created_at
  end

  def unread?
    !read?
  end

  def mark_as_read
    self.read = true
    self.read_at = DateTime.now
    self.save
  end

  def append(type, address, first_name = nil, last_name = nil)
    current = self.[](type)
    current.append(email_with_name(address, first_name, last_name))
    self.[]=(type, current)
  end

  def mark_as_unread
    self.read = false
    self.read_at = nil
    self.save
  end

  def set_message(*args)
    self.body = ApplicationController.render(*args)
    self.save
  end

  def email
    ActionMailer::Base.mail(
      subject: self.subject,
      to: self.to,
      from: self.from,
      cc: self.cc,
      bcc: self.bcc,
      reply_to: self.reply_to,
      content_type: self.content_type,
      body: self.body
    )
  end

  def deliver_now
    email.deliver_now
    self.update_column(:sent_at, DateTime.now)
  end

  class_methods do
    def unread
      where(:read => false)
    end
  end

  private
  def email_with_name(address, first_name = nil, last_name = nil)
    #Do not use comma as CsvSerializer uses
    first_name.gsub!(",", " ") if first_name
    last_name.gsub!(",", " ") if last_name

    ActionMailer::Base.email_address_with_name(address, [first_name, last_name].join(" "))
  end
end
