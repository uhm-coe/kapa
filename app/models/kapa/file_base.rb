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

  def type
    "File"
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
      files = Kapa::File.eager_load({:users => :person}, :person).order("files.created_at DESC").limit(500)
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

    def csv_format
      {:id_number => [:person, :id_number],
       :last_name => [:person, :last_name],
       :first_name => [:person, :first_name],
       :cur_street => [:person, :cur_street],
       :cur_city => [:person, :cur_city],
       :cur_state => [:person, :cur_stateperson, :contact, :cur_state],
       :cur_postal_code => [:person, :cur_postal_code],
       :cur_phone => [:person, :cur_phone],
       :email => [:person, :email],
       :updated => [:updated_at]}
    end

    def inline_content_types
      ["application/pdf", "application/x-pdf", "audio/mpeg", "image/gif", "image/jpeg", "image/png", "text/html", "text/plain"]
    end
  end
end
