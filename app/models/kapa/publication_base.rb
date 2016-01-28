module Kapa::PublicationBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person

    validates_presence_of :person_id
    before_save :format_dates
  end

  def format_dates
    unless self.pubdate.nil?
      date = self.pubdate.to_time
      self.pubyear = date.strftime("%Y")
      self.pubmonth = date.strftime("%B")
    end
  end
end
