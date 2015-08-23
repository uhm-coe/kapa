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
  kapa_persons
  kapa_contacts
  kapa_curriculums
  kapa_transition_points
  kapa_transition_actions
  kapa_enrollments
  kapa_files
  kapa_forms
  kapa_exams
  kapa_reports
  kapa_advising_sessions
  kapa_course_offers
  kapa_course_registrations
  kapa_practicum_placements
  kapa_practicum_sites
  kapa_assessment_criterions
  kapa_assessment_datasets
  kapa_programs
  kapa_program_offers
  kapa_properties
  kapa_rubrics
  kapa_terms
  kapa_users
}