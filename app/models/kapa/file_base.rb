module Kapa::FileBase
  extend ActiveSupport::Concern

  included do
    self.inheritance_column = nil
    belongs_to :person
    has_attached_file :data
    validates_presence_of :person_id
  end

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

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      files = Kapa::File.eager_load([:person]).order("files.created_at DESC").limit(500)
      files = files.column_matches("name" => filter.name) if filter.name.present?
#      files = files.depts_scope(filter.user.depts, "public = 'Y'")
      return files
    end

    def csv_format
      {:id_number => [:person, :id_number],
       :last_name => [:person, :last_name],
       :first_name => [:person, :first_name],
       :cur_street => [:person, :contact, :cur_street],
       :cur_city => [:person, :contact, :cur_city],
       :cur_state => [:person, :contact, :cur_stateperson, :contact, :cur_state],
       :cur_postal_code => [:person, :contact, :cur_postal_code],
       :cur_phone => [:person, :contact, :cur_phone],
       :email => [:person, :contact, :email],
       :updated => [:updated_at]}
    end
  end
end
