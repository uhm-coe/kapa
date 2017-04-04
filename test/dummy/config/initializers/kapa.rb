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

# Available routes
Rails.configuration.available_routes = %w{
  kapa_persons
  kapa_files
  kapa_forms
  kapa_reports
  kapa_assessment_rubrics
  kapa_assessment_criterions
  kapa_users
  kapa_user_assignments
  kapa_notifications
  kapa_datasets
  kapa_properties
  kapa_exams
  kapa_curriculums
  kapa_transition_points
  kapa_transition_actions
  kapa_enrollments
  kapa_advising_sessions
  kapa_courses
  kapa_course_registrations
  kapa_practicum_placements
  kapa_practicum_logs
  kapa_practicum_sites
  kapa_programs
  kapa_program_offers
  kapa_terms
}

Rails.configuration.filter_defaults = {
   :key => "",
   :active => 1,
   :property => "major",
   :transition_point_type => "admission",
   :date_start => Date.today,
   :date_end => Date.today,
   :per_page => Rails.configuration.items_per_page
}
