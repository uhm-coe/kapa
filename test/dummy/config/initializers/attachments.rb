# Be sure to restart your server when you modify this file.


#Location of attachment files
Rails.configuration.attachment_root = "/srv/attachments"

# Directory structure of attachment files
Paperclip::Attachment.default_options[:path] = "#{Rails.configuration.attachment_root}/:class/:attachment/:id_partition/:style.:extension"
