# Be sure to restart your server when you modify this file.

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
Rails.configuration.roles["Adviser"] = {
    kapa_persons: '2',
    kapa_persons_scope: '2',
    kapa_contacts: '2',
    kapa_contacts_scope: '2',
    kapa_curriculums: '2',
    kapa_curriculums_scope: '2',
    kapa_transition_points: '2',
    kapa_transition_points_scope: '2',
    kapa_transition_actions: '2',
    kapa_transition_actions_scope: '2',
    kapa_enrollments: '2',
    kapa_enrollments_scope: '2',
    kapa_files: '2',
    kapa_files_scope: '2',
    kapa_forms: '2',
    kapa_forms_scope: '2',
    kapa_exams: '2',
    kapa_exams_scope: '2',
    kapa_advising_sessions: '2',
    kapa_advising_sessions_scope: '2'
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
