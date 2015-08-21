# Location of storing attachment files
Paperclip::Attachment.default_options[:path] = "/home/vagrant/files/class/:id_partition/:style.:extension"

# Mailer setting
Rails.configuration.mail_from = "admin@localhost"

# Location of your public key to encrypt database fields
Rails.configuration.public_key = "#{Rails.root}/config/kapa.pub"

# Regular expression for campus ID and email
Rails.configuration.regex_id_number = '^[\d]{8}$' # Exactly 8 digits
Rails.configuration.regex_email = '^[A-Z0-9_%+-]+@hawaii.edu$'

# Default items per page on list views
Rails.configuration.items_per_page = 20

# Default LDAP configuration
Rails.configuration.ldap = nil

Rails.configuration.available_routes = %w{
  kapa_main_persons
  kapa_main_contacts
  kapa_main_curriculums
  kapa_main_transition_points
  kapa_main_transition_actions
  kapa_main_enrollments
  kapa_document_files
  kapa_document_forms
  kapa_document_exams
  kapa_document_reports
  kapa_advising_sessions
  kapa_course_offers
  kapa_course_registrations
  kapa_practicum_placements
  kapa_practicum_sites
  kapa_admin_criterions
  kapa_admin_datasets
  kapa_admin_programs
  kapa_admin_program_offers
  kapa_admin_properties
  kapa_admin_rubrics
  kapa_admin_terms
  kapa_admin_users
}
