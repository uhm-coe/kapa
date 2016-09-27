module Kapa::FacultyPublicationBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    has_many :faculty_publication_authors
    has_many :authors, :class_name => "FacultyPublicationAuthor"

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
    unless self.published_date.blank?
      date = self.published_date.to_time
      self.year = date.strftime("%Y")
      self.month = date.strftime("%B")
    end
  end

  def parse(bibtex_string)
    bibtex = BibTeX.parse(bibtex_string)
    entry = bibtex[-1]
    self.location = entry.[](:address)
    self.annote = entry.[](:annote)
    self.author = entry.[](:author)
    self.book_title = entry.[](:booktitle)
    self.book_chapter = entry.[](:chapter)
    self.crossref = entry.[](:crossref)
    self.edition = entry.[](:edition)
    self.editor = entry.[](:editor)
    self.how_published = entry.[](:howpublished)
    self.institution = entry.[](:institution)
    self.journal = entry.[](:journal)
    self.key = entry.[](:key)
    self.month = entry.[](:month)
    self.note = entry.[](:note)
    self.issue_number = entry.[](:number)
    self.organization = entry.[](:organization)
    self.pages = entry.[](:pages)
    self.publisher = entry.[](:publisher)
    self.school = entry.[](:school)
    self.series = entry.[](:series)
    self.title = entry.[](:title)
    self.vol = entry.[](:volume)
    self.year = entry.[](:year)
  end

  def to_bibtex
    bib = BibTeX::Bibliography.new
    bib << BibTeX::Entry.new({
              bibtex_type: self.type,
              bibtex_key: self.id,
              location: self.location,
              annote: self.annote,
              author: self.author,
              booktitle: self.book_title,
              chapter: self.book_chapter,
              crossref: self.crossref,
              edition: self.edition,
              editor: self.editor,
              howpublished: self.how_published,
              institution: self.institution,
              journal: self.journal,
              key: self.key,
              month: self.month,
              note:  self.note,
              number: self.issue_number,
              organization: self.organization,
              pages: self.pages,
              publisher: self.publisher,
              school: self.school,
              series: self.series,
              title: self.title,
              volume: self.vol,
              year: self.year
            })
    return bib
  end

  def citation(options = {style: "apa", format: "html", locale: "en"})
   cp = CiteProc::Processor.new(options)
    cp.import(self.to_bibtex.to_citeproc)
    cp.render(:bibliography, id: self.id).first.html_safe
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      publications = Kapa::FacultyPublication.eager_load([:person, :authors]).order("faculty_publications.title")
      publications = publications.column_matches("faculty_publications.title" => filter.title) if filter.title.present?
      publications = publications.where("faculty_publications.type" => filter.publication_type) if filter.publication_type.present?
      publications = publications.where(:published_date => filter.published_date_start.to_date..filter.published_date_end.to_date) if filter.published_date_start.present? and filter.published_date_end.present?
      publications = publications.column_matches(:keyword => filter.keyword) if filter.keyword.present?
      return publications
    end

    def csv_format
      {:id_number => [:person, :id_number],
       :last_name => [:person, :last_name],
       :first_name => [:person, :first_name],
       :cur_street => [:person, :cur_street],
       :cur_city => [:person, :cur_city],
       :cur_state => [:person, :cur_state],
       :cur_postal_code => [:person, :cur_postal_code],
       :cur_phone => [:person, :cur_phone],
       :email => [:person, :email],
       :type => [:type],
       :title => [:title],
       :dept => [:dept],
       :published_date => [:published_date],
       :document_identifier => [:documentidentifier],
       :vol => [:pubvol],
       :num_of_vol => [:pubnumofvol],
       :pages => [:pubpages],
       :publisher => [:pubpublisher],
       :location => [:publocation],
       :editor => [:pubeditor],
       :location => [:publocation],
       :edition => [:pubedition],
       :abstract => [:pubabstract]}
    end
  end
end
