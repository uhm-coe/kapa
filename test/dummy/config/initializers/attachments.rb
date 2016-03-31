# Be sure to restart your server when you modify this file.

# Directory structure of attachment files
Paperclip::Attachment.default_options[:path] = "#{Rails.configuration.attachment_root}/attachments/:class/:id_partition/:style.:extension"
