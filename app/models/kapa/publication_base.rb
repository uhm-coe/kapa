module Kapa::PublicationBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person

    has_attached_file :thumbnail
    # validates_attachment_content_type :thumbnail, content_type: /\Aimage/ # TODO: Requires Paperclip >4.0

    validates_presence_of :person_id
    before_save :format_dates
  end

  def format_dates
    unless self.pubdate.blank?
      date = self.pubdate.to_time
      self.pubyear = date.strftime("%Y")
      self.pubmonth = date.strftime("%B")
    end
  end
end
