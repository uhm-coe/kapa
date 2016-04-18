# Be sure to restart your server when you modify this file.

# Define default user levels and scopes
Rails.configuration.user_levels = [["No Access", "0"], ["Read", "10"], ["Write", "20"], ["Manage", "30"]]
Rails.configuration.user_scopes = [["Assigned records", "10"], ["Assigned or Dept records", "20"], ["All records", "30"]]
Rails.configuration.user_status = [["No Access", "0"],["Guest" , "10"],["User" , "30"]]
Rails.configuration.user_categories = [["LDAP", "ldap"],["Local" , "local"]]

# Define user roles (pre-defined permissions)
Rails.configuration.roles = {}
Rails.configuration.roles["Admin"] = Rails.configuration.available_routes.each_with_object({}) {|route, permission|
  permission["#{route}"] = '30'
  permission["#{route}_scope"] = '30'
}
Rails.configuration.roles["None"] = Rails.configuration.available_routes.each_with_object({}) {|route, permission|
  permission["#{route}"] = '0'
  permission["#{route}_scope"] = '0'
}
Rails.configuration.roles["Adviser"] = {
    kapa_persons: '20',
    kapa_persons_scope: '20',
    kapa_contacts: '20',
    kapa_contacts_scope: '20',
    kapa_curriculums: '20',
    kapa_curriculums_scope: '20',
    kapa_transition_points: '20',
    kapa_transition_points_scope: '20',
    kapa_transition_actions: '20',
    kapa_transition_actions_scope: '20',
    kapa_enrollments: '20',
    kapa_enrollments_scope: '20',
    kapa_files: '20',
    kapa_files_scope: '20',
    kapa_forms: '20',
    kapa_forms_scope: '20',
    kapa_exams: '20',
    kapa_exams_scope: '20',
    kapa_advising_sessions: '20',
    kapa_advising_sessions_scope: '20'
}

instructor_permission = {}
instructor_permission["kapa_courses"] = '20'
instructor_permission["kapa_courses_scope"] = '20'
instructor_permission["kapa_course_registrations"] = '20'
instructor_permission["kapa_course_registrations_scope"] = '20'
Rails.configuration.roles["Instructor"] = instructor_permission
