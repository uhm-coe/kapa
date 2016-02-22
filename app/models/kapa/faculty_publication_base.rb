module Kapa::FacultyPublicationBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    has_many :faculty_publications_authors
    has_many :authors, :class_name => "FacultyPublicationsAuthor"

    has_attached_file :thumbnail
    # validates_attachment_content_type :thumbnail, content_type: /\Aimage/ # TODO: Requires Paperclip >4.0

    validates_presence_of :person_id
    before_save :format_dates
  end

  def authors_ordered
    authors.order("sequence IS NULL, sequence ASC, id") # NULLs last
  end

  def author_names
    authors_ordered.map { |author| author.full_name }.join("; ")
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
      publications = Kapa::FacultyPublication.eager_load([:person, :authors]).order("faculty_publications.pubtitle")
      publications = publications.column_matches("faculty_publications.pubtitle" => filter.pubtitle) if filter.pubtitle.present?
      publications = publications.where("faculty_publications.pubtype" => filter.pubtype) if filter.pubtype.present?
      publications = publications.where(:pubdate => filter.pubdate_start..filter.pubdate_end) if filter.pubdate_start.present? and filter.pubdate_end.present?
      publications = publications.column_matches(:pubkeyword => filter.keyword) if filter.keyword.present?
      return publications
    end

    def csv_format
      {:id_number => [:person, :id_number],
       :last_name => [:person, :last_name],
       :first_name => [:person, :first_name],
       :cur_street => [:person, :contact, :cur_street],
       :cur_city => [:person, :contact, :cur_city],
       :cur_state => [:person, :contact, :cur_state],
       :cur_postal_code => [:person, :contact, :cur_postal_code],
       :cur_phone => [:person, :contact, :cur_phone],
       :email => [:person, :contact, :email],
       :pubtype => [:pubtype],
       :pubtitle => [:pubtitle],
       :dept => [:dept],
       :pubdate => [:pubdate],
       :documentidentifier => [:documentidentifier],
       :pubvol => [:pubvol],
       :pubnumofvol => [:pubnumofvol],
       :pubpages => [:pubpages],
       :pubpublisher => [:pubpublisher],
       :publocation => [:publocation],
       :pubeditor => [:pubeditor],
       :publocation => [:publocation],
       :pubedition => [:pubedition],
       :pubabstract => [:pubabstract]}
    end
  end
end
