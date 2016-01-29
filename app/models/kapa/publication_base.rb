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

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      publications = Kapa::Publication.eager_load([:person]).order("publications.pubtitle")
      publications = publications.column_matches("publications.pubtitle" => filter.pubtitle) if filter.pubtitle.present?
      publications = publications.where("publications.pubtype" => filter.pubtype) if filter.pubtype.present?
      publications = publications.where(:pubdate => filter.pubdate_start..filter.pubdate_end) if filter.pubdate_start.present? and filter.pubdate_end.present?
      publications = publications.where("publications.pubkeyword LIKE ?", "%#{filter.keyword}%") if filter.keyword.present?
      publications = publications.where("publications.pubcontributor LIKE ?", "%#{filter.author}%") if filter.author.present?
      return publications
    end
  end
end
