module Kapa::Concerns::Document
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
end
