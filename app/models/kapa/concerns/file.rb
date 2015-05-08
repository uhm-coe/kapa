module Kapa::Concerns::File
  extend ActiveSupport::Concern

  included do
    self.inheritance_column = nil
    belongs_to :person
    has_attached_file :data
    validates_presence_of :person_id
  end # included

  def url(*args)
    data.url(*args)
  end

  def content_type
    if data_content_type == "application/x-pdf"
      "application/pdf"
    else
      data_content_type
    end
  end

  def file_size
    data_file_size
  end

  def date
    self.updated_at
  end

  module ClassMethods
    def search(filter, options = {})
      files = Kapa::File.includes([:person])
      files = files.where("files.type" => filter.type.to_s) if filter.type.present?
      files = files.depts_scope(filter.user.depts, "public = 'Y'")
      return files
    end

    def to_csv(filter, options = {})
      files = self.search(filter).order("submitted_at desc, persons.last_name, persons.first_name")
      CSV.generate do |csv|
        csv << self.csv_columns
        files.each do |c|
          csv << self.csv_row(c)
        end
      end
    end

    def csv_columns
      [:id_number,
       :last_name,
       :first_name,
       :ssn,
       :ssn_agreement,
       :cur_street,
       :cur_city,
       :cur_state,
       :cur_postal_code,
       :cur_phone,
       :email,
       :updated]
    end

    def csv_row(c)
      [c.rsend(:person, :id_number),
       c.rsend(:person, :last_name),
       c.rsend(:person, :first_name),
       c.rsend(:person, :ssn),
       c.rsend(:person, :ssn_agreement),
       c.rsend(:person, :contact, :cur_street),
       c.rsend(:person, :contact, :cur_city),
       c.rsend(:person, :contact, :cur_state),
       c.rsend(:person, :contact, :cur_postal_code),
       c.rsend(:person, :contact, :cur_phone),
       c.rsend(:person, :contact, :email),
       c.rsend(:updated_at)]
    end
  end
end
