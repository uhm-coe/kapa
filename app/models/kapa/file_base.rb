module Kapa::FileBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person, :optional => true
    belongs_to :attachable, :polymorphic => true, :optional => true
    has_many :user_assignments, :as => :assignable
    has_many :users, :through => :user_assignments

    has_attached_file :data
    validates_attachment_content_type :data, :content_type => Rails.configuration.attachment_content_types
  end

  def document_id
    "FL" + self.id.to_s.rjust(9, '0')
  end

  def document_type
    "File"
  end

  def document_title
    self.name
  end

  def document_date
    self.updated_at
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

  def status_desc
    self.desc_of(:status)
  end
  
  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      files = Kapa::File.eager_load({:users => :person}, :person).where(:active => true).order("files.created_at DESC")
      files = files.column_matches("name" => filter.name) if filter.name.present?

      case filter.user.access_scope(:kapa_files)
        when 30
          # do nothing
        when 20
          files = files.depts_scope(filter.user.depts, filter.user.id, "public = 'Y'")
        when 10
          files = files.assigned_scope(filter.user.id)
        else
          files = files.none
      end

      return files
    end

    def inline_content_types
      ["application/pdf", "application/x-pdf", "audio/mpeg", "image/gif", "image/jpeg", "image/png", "text/html", "text/plain"]
    end
  end
end
