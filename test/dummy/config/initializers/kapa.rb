# Be sure to restart your server when you modify this file.

# Location of storing attachment files
Rails.configuration.attachment_root = "/home/vagrant/attachments"

# Location of your public key to encrypt database fields
Rails.configuration.public_key = "#{Rails.root}/config/kapa.pub"

# Regular expression for campus ID and email
Rails.configuration.regex_id_number = '^[\d]{8}$' # Exactly 8 digits
Rails.configuration.regex_email = '^[A-Z0-9_%+-]+@hawaii.edu$'

# Default items per page on list views
Rails.configuration.items_per_page = 20

# Selections for pagination on list views
Rails.configuration.items_per_page_selections = [10, 20, 30, 40, 50]

# Available routes
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
  kapa_cases
  kapa_case_actions
  kapa_courses
  kapa_course_registrations
  kapa_practicum_placements
  kapa_practicum_logs
  kapa_practicum_sites
  kapa_assessment_rubrics
  kapa_assessment_criterions
  kapa_datasets
  kapa_programs
  kapa_program_offers
  kapa_properties
  kapa_terms
  kapa_users
  user_assignments
  kapa_faculty_publications
  kapa_faculty_publication_authors
  kapa_faculty_service_activities
  kapa_faculty_awards
  kapa_cases
  kapa_case_persons
  kapa_case_actions
}
