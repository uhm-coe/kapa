module Kapa::NotificationBase
  extend ActiveSupport::Concern

  included do
    belongs_to :user
    belongs_to :attachable, :polymorphic => true

    validates_presence_of :user_id
  end

  def date
    self.created_at
  end

  def unread?
    !read?
  end

  def mark_as_read!
    self.read = true
    self.read_at = DateTime.now
    self.save
  end

  def mark_as_unread!
    self.read = false
    self.read_at = nil
    self.save
  end

  def send_email!
    begin
      # email = UserMailer.build(:to => "#{self.user.person.full_name_ordered} <brysonkm@hawaii.edu>", :subject => self.title, :body => self.body)
      # email.deliver_now
    rescue StandardError => e
      logger.debug(e)
    end
  end

  class_methods do
    def unread
      where(:read => false)
    end
  end
end
