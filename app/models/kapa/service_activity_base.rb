module Kapa::ServiceActivityBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person

    has_attached_file :image
    # validates_attachment_content_type :thumbnail, content_type: /\Aimage/ # TODO: Requires Paperclip >4.0

    validates_presence_of :person_id
  end

  class_methods do
  end
end
