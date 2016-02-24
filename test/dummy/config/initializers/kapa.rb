# Location of storing attachment files
Paperclip::Attachment.default_options[:path] = "/home/vagrant/attachments/:class/:id_partition/:style.:extension"

# Mailer setting
Rails.configuration.mail_from = "admin@localhost"

# Location of your public key to encrypt database fields
Rails.configuration.public_key = "#{Rails.root}/config/kapa.pub"

# Regular expression for campus ID and email
Rails.configuration.regex_id_number = '^[\d]{8}$' # Exactly 8 digits
Rails.configuration.regex_email = '^[A-Z0-9_%+-]+@hawaii.edu$'

# Default items per page on list views
Rails.configuration.items_per_page = 20

# Default LDAP configuration.  This LDAP will be used for user authentication
Rails.configuration.ldap = Net::LDAP.new(Rails.application.secrets.uh_ldap)
Rails.configuration.ldap_base = "ou=people,dc=hawaii,dc=edu"
Rails.configuration.ldap_filter = "(uid = ?)"

# Datasources available for datasets
Rails.configuration.datasources = []

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
  kapa_faculty_publications
  kapa_faculty_publication_authors
  kapa_faculty_service_activities
  kapa_faculty_awards
}

# Define user roles (pre-defined permissions)
Rails.configuration.roles = {}
Rails.configuration.roles["Admin"] = Rails.configuration.available_routes.each_with_object({}) {|route, permission|
                                       permission["#{route}"] = '3'
                                       permission["#{route}_scope"] = '3'
                                     }
Rails.configuration.roles["None"] = Rails.configuration.available_routes.each_with_object({}) {|route, permission|
                                      permission["#{route}"] = '0'
                                      permission["#{route}_scope"] = '0'
                                    }
adviser_permission = {}
adviser_permission["kapa_persons"] = '2'
adviser_permission["kapa_persons_scope"] = '2'
adviser_permission["kapa_contacts"] = '2'
adviser_permission["kapa_contacts_scope"] = '2'
adviser_permission["kapa_curriculums"] = '2'
adviser_permission["kapa_curriculums_scope"] = '2'
adviser_permission["kapa_transition_points"] = '2'
adviser_permission["kapa_transition_points_scope"] = '2'
adviser_permission["kapa_transition_actions"] = '2'
adviser_permission["kapa_transition_actions_scope"] = '2'
adviser_permission["kapa_enrollments"] = '2'
adviser_permission["kapa_enrollments_scope"] = '2'
adviser_permission["kapa_files"] = '2'
adviser_permission["kapa_files_scope"] = '2'
adviser_permission["kapa_forms"] = '2'
adviser_permission["kapa_forms_scope"] = '2'
adviser_permission["kapa_exams"] = '2'
adviser_permission["kapa_exams_scope"] = '2'
adviser_permission["kapa_advising_sessions"] = '2'
adviser_permission["kapa_advising_sessions_scope"] = '2'
Rails.configuration.roles["Adviser"] = adviser_permission
instructor_permission = {}
instructor_permission["kapa_courses"] = '2'
instructor_permission["kapa_courses_scope"] = '2'
instructor_permission["kapa_course_registrations"] = '2'
instructor_permission["kapa_course_registrations_scope"] = '2'
Rails.configuration.roles["Instructor"] = instructor_permission
