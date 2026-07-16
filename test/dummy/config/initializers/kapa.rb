# Be sure to restart your server when you modify this file.

# Location of your public key to encrypt database fields
Rails.configuration.public_key = "#{Rails.root}/config/kapa.pub"

# Regular expression for campus ID and email
Rails.configuration.regex_id_number = '^[\d]{8}$' # Exactly 8 digits
Rails.configuration.regex_email = '^[A-Z0-9_%+-]+@hawaii.edu$'

# Default items per page on list views
Rails.configuration.items_per_page = 20

# Selections for pagination on list views
Rails.configuration.items_per_page_selections = [10, 20, 30, 40, 50]

# Configure bootswatch theme (Run rake tmp:cache:clear after updating this)
Rails.configuration.theme = "cerulean"

# Available routes
Rails.configuration.available_routes = %w{
  kapa_persons
  kapa_files
  kapa_forms
  kapa_form_templates
  kapa_form_template_fields
  kapa_texts
  kapa_text_templates
  kapa_users
  kapa_user_assignments
  kapa_notifications
  kapa_properties
  kapa_terms
}

Rails.configuration.filter_defaults = {
   :key => "",
   :active => 1,
   :property => "dept",
   :date_start => Date.today,
   :date_end => Date.today,
   :per_page => Rails.configuration.items_per_page
}

# Set timezone
Rails.configuration.time_zone = 'Hawaii'

# Configure bootswatch theme (Run rake tmp:cache:clear after updating this)
Rails.configuration.theme = "united"

# Bootstrap form helpers (form-controls and labels are automatically defined for the helpers listed below)
Rails.configuration.form_helpers = %w{
  text_field
  password_field
  color_field
  date_field
  datetime_field
  datetime_local_field
  email_field
  month_field
  number_field
  range_field
  search_field
  telephone_field
  time_field
  url_field
  week_field      
  file_field
  text_area
  date_picker 
  datetime_picker
  time_picker 
  select
  person_select 
  text_template_select
  model_select
  property_select
  term_select
  program_select
  history_select
  user_select 
  check_box
  radio_button 
  static
}

# A field used for serializing data
Rails.configuration.serialize_field = :yml

#Location of attachment files
Rails.configuration.attachment_root = Rails.env.production? ? "/srv/attachments" : Rails.root.join("tmp/attachments")

#Allowed content types
Rails.configuration.attachment_content_types = ["application/pdf", "application/x-pdf", "audio/mpeg", "image/gif", "image/jpeg", "image/png", "text/plain"]

# Directory structure of attachment files
Paperclip::Attachment.default_options[:path] = "#{Rails.configuration.attachment_root}/:class/:attachment/:id_partition/:style.:extension"

#Authlogic configuration
Rails.configuration.acts_as_authentic_options = {}

# Define default user levels and scopes
Rails.configuration.user_levels = [["No Access", "0"], ["Read", "10"], ["Write", "20"], ["Manage", "30"]]
Rails.configuration.user_scopes = [["Assigned records", "10"], ["Assigned or Dept records", "20"], ["All records", "30"]]
Rails.configuration.user_status = [["No Access", "0"],["Active Guest" , "10"],["Active User" , "30"], ["Active User (Overridden)" , "40"]]
Rails.configuration.user_categories = [["LDAP", "ldap"],["Local" , "local"]]

# Define user roles (permissions to each kapa controller)
# R = Read (index and show)
# U = Update
# C = Create
# D = Destroy
# I = Import
# E = Export
# M = Manage
Rails.configuration.roles = {}
Rails.configuration.roles["Admin"] = Rails.configuration.available_routes.each_with_object({}) {|route, permission|
  permission["#{route}"] = 'RUCDIEM'
  permission["#{route}_scope"] = '30'
}
Rails.configuration.roles["None"] = Rails.configuration.available_routes.each_with_object({}) {|route, permission|
  permission["#{route}"] = ''
  permission["#{route}_scope"] = '0'
}
