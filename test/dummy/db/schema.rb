# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20141220051200) do

  create_table "advising_actions", :force => true do |t|
    t.integer "advising_id", :null => false
    t.date    "action_date"
    t.string  "action"
    t.string  "specify"
    t.text    "comment"
    t.string  "handled_by"
  end

  create_table "advising_sessions", :force => true do |t|
    t.integer  "person_id",                :null => false
    t.date     "session_date"
    t.string   "session_type"
    t.text     "note"
    t.string   "task"
    t.string   "action"
    t.string   "specify"
    t.string   "classification"
    t.string   "current_field"
    t.string   "interest"
    t.string   "location"
    t.string   "handled_by"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "mail_address"
    t.string   "phone"
    t.string   "identity_note"
    t.string   "contact_note"
    t.string   "dept"
    t.integer  "curriculum_enrollment_id"
    t.text     "yml"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "curriculum_id"
    t.integer  "user_primary_id"
    t.integer  "user_secondary_id"
  end

  add_index "advising_sessions", ["curriculum_id"], :name => "index_advising_sessions_on_curriculum_id"
  add_index "advising_sessions", ["handled_by"], :name => "index_advisings_on_handled_by"
  add_index "advising_sessions", ["person_id"], :name => "index_advisings_on_person_id"
  add_index "advising_sessions", ["session_date"], :name => "index_advisings_on_inquiry_date"
  add_index "advising_sessions", ["task"], :name => "index_advisings_on_task"

  create_table "assessment_course_registrations", :force => true do |t|
    t.integer  "assessment_course_id"
    t.integer  "person_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "yml"
    t.text     "xml"
  end

  add_index "assessment_course_registrations", ["assessment_course_id", "person_id"], :name => "index_assessment_course_registrations_on_course_id_and_person_id", :unique => true

  create_table "assessment_courses", :force => true do |t|
    t.string   "academic_period", :limit => 150
    t.string   "crn",             :limit => 150
    t.string   "subject"
    t.string   "number"
    t.string   "section"
    t.string   "title"
    t.string   "instructor"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "yml"
    t.text     "xml"
    t.string   "final_grade"
  end

  add_index "assessment_courses", ["academic_period", "crn"], :name => "index_assessment_courses_on_academic_period_and_crn", :unique => true

  create_table "assessment_criterions", :force => true do |t|
    t.string   "criterion"
    t.text     "criterion_desc"
    t.text     "criterion_html"
    t.string   "standard"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assessment_rubric_id"
    t.text     "yml"
    t.text     "xml"
    t.string   "type",                 :default => "default", :null => false
    t.string   "type_option"
  end

  create_table "assessment_rubrics", :force => true do |t|
    t.string   "title"
    t.string   "course"
    t.string   "reference_url"
    t.string   "dept"
    t.text     "yml"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "program"
    t.string   "assessment_type"
    t.string   "transition_point"
    t.string   "academic_period_start", :default => "200010"
    t.string   "academic_period_end",   :default => "999999"
  end

  add_index "assessment_rubrics", ["academic_period_end"], :name => "index_assessment_rubrics_on_academic_period_end"
  add_index "assessment_rubrics", ["academic_period_start"], :name => "index_assessment_rubrics_on_academic_period_start"
  add_index "assessment_rubrics", ["course"], :name => "index_assessment_rubrics_on_course"

  create_table "assessment_scores", :force => true do |t|
    t.integer  "assessment_scorable_id"
    t.integer  "assessment_criterion_id"
    t.string   "rating"
    t.string   "rated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "yml"
    t.text     "xml"
    t.string   "assessment_scorable_type"
    t.string   "academic_period"
  end

  add_index "assessment_scores", ["assessment_scorable_type", "assessment_scorable_id", "assessment_criterion_id"], :name => "index_assessment_scores_on_scorable_and_criterion_id", :unique => true

  create_table "contacts", :force => true do |t|
    t.integer  "entity_id",       :null => false
    t.string   "entity_type"
    t.string   "cur_street"
    t.string   "cur_city"
    t.string   "cur_state"
    t.string   "cur_postal_code"
    t.string   "per_street"
    t.string   "per_city"
    t.string   "per_state"
    t.string   "per_postal_code"
    t.string   "cur_phone"
    t.string   "per_phone"
    t.string   "business_phone"
    t.string   "mobile_phone"
    t.string   "fax"
    t.string   "email"
    t.string   "note"
    t.text     "yml"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["entity_id"], :name => "index_contacts_on_entity_id"

  create_table "curriculum_actions", :force => true do |t|
    t.integer  "curriculum_event_id"
    t.string   "action"
    t.string   "action_specify"
    t.date     "action_date"
    t.string   "action_note"
    t.string   "handled_by"
    t.integer  "sequence",            :default => 99
    t.string   "context",             :default => "", :null => false
    t.text     "yml"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "curriculum_actions", ["action"], :name => "index_curriculum_actions_on_action"
  add_index "curriculum_actions", ["curriculum_event_id"], :name => "index_curriculum_actions_on_curriculum_id"

  create_table "curriculum_admissions", :force => true do |t|
    t.integer "curriculum_event_id"
    t.string  "population"
    t.string  "location"
    t.date    "coe_received_date"
    t.date    "coe_interviewed_date"
    t.date    "caf_received_date"
    t.date    "caf_returned_date"
    t.date    "lack_letter_sent_date"
    t.date    "rsvp_date"
    t.date    "tb_date"
    t.string  "previous_application"
    t.integer "cat1"
    t.integer "cat2"
    t.integer "cat3"
    t.integer "cat4"
    t.integer "cat5"
    t.integer "cat6"
    t.string  "trans1_from"
    t.string  "trans2_from"
    t.string  "trans3_from"
    t.string  "trans4_from"
    t.date    "trans1_received_date"
    t.date    "trans2_received_date"
    t.date    "trans3_received_date"
    t.date    "trans4_received_date"
    t.string  "trans_all_received"
    t.string  "assigned_to"
    t.text    "application_note"
    t.string  "status"
    t.decimal "cum_gpa",                   :precision => 6, :scale => 3
    t.decimal "major_cum_gpa",             :precision => 6, :scale => 3
    t.string  "field_exp_req1"
    t.string  "field_exp_req2"
    t.string  "field_exp_req3"
    t.string  "field_exp_req4"
    t.integer "field_exp_points"
    t.string  "praxis_reading_passed"
    t.string  "praxis_math_passed"
    t.string  "praxis_writing_passed"
    t.string  "praxis_conknow_passed"
    t.integer "praxis_points"
    t.string  "interview_first_passed"
    t.date    "interview_first_date"
    t.string  "interview_first_by"
    t.text    "interview_first_note"
    t.string  "interview_second_passed"
    t.date    "interview_second_date"
    t.string  "interview_second_by"
    t.text    "interview_second_note"
    t.decimal "interview_points",          :precision => 6, :scale => 3
    t.string  "evaluation_complete"
    t.text    "admission_note"
    t.decimal "score",                     :precision => 6, :scale => 3
    t.string  "aa_degree",                                               :default => "N"
    t.string  "previous_application_when"
    t.date    "fe_received_date"
    t.string  "praxis_composit_passed"
    t.string  "coursework_req01"
    t.string  "coursework_req02"
    t.string  "coursework_req03"
    t.string  "coursework_req04"
    t.string  "coursework_req05"
    t.string  "coursework_req06"
    t.string  "coursework_req07"
    t.string  "coursework_req08"
    t.string  "coursework_req09"
    t.string  "coursework_req10"
    t.string  "cum_gpa_type"
    t.string  "major_cum_gpa_type"
    t.date    "praxis1_received_date"
    t.date    "praxis2_received_date"
    t.string  "aa_degree_when"
    t.string  "current_college"
  end

  add_index "curriculum_admissions", ["curriculum_event_id"], :name => "index_curriculum_admissions_on_curriculum_id"

  create_table "curriculum_events", :force => true do |t|
    t.integer  "person_id",                                 :null => false
    t.string   "academic_period",          :default => "",  :null => false
    t.string   "program"
    t.string   "degree"
    t.string   "second_degree"
    t.string   "major_primary"
    t.string   "major_secondary"
    t.string   "distribution"
    t.string   "location"
    t.string   "context",                  :default => "",  :null => false
    t.string   "priority"
    t.string   "status"
    t.string   "assigned_to"
    t.integer  "form_id"
    t.text     "note"
    t.text     "yml"
    t.text     "xml"
    t.integer  "curriculum_enrollment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "track",                    :default => "N"
    t.string   "category"
    t.string   "dept"
  end

  add_index "curriculum_events", ["academic_period"], :name => "index_curriculum_events_on_academic_period"
  add_index "curriculum_events", ["form_id"], :name => "index_curriculum_events_on_form_id"

  create_table "curriculum_graduations", :force => true do |t|
    t.integer "curriculum_event_id"
    t.decimal "cum_gpa",             :precision => 6, :scale => 3
    t.integer "regular_credits"
    t.integer "transfer_credits"
    t.text    "application_note"
    t.string  "assigned_to"
    t.text    "graduation_note"
  end

  add_index "curriculum_graduations", ["curriculum_event_id"], :name => "index_curriculum_graduations_on_curriculum_id"

  create_table "curriculums", :force => true do |t|
    t.integer  "person_id",                               :null => false
    t.integer  "program_id",                              :null => false
    t.string   "academic_period",   :default => "000000", :null => false
    t.string   "second_degree"
    t.string   "major_primary"
    t.string   "major_secondary"
    t.string   "track"
    t.string   "distribution"
    t.string   "location"
    t.string   "cohort"
    t.string   "status"
    t.string   "dept"
    t.integer  "user_primary_id"
    t.integer  "user_secondary_id"
    t.boolean  "active",            :default => false
    t.text     "note"
    t.text     "yml"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "curriculums", ["academic_period"], :name => "index_curriculums_on_academic_period"
  add_index "curriculums", ["dept"], :name => "index_curriculums_on_dept"
  add_index "curriculums", ["person_id"], :name => "index_curriculums_on_person_id"
  add_index "curriculums", ["program_id"], :name => "index_curriculums_on_program_id"
  add_index "curriculums", ["user_primary_id"], :name => "index_curriculums_on_user_primary_id"
  add_index "curriculums", ["user_secondary_id"], :name => "index_curriculums_on_user_secondary_id"

  create_table "documents", :force => true do |t|
    t.integer  "person_id",                          :null => false
    t.string   "name"
    t.string   "category"
    t.string   "status"
    t.string   "uploaded_by"
    t.string   "dept"
    t.string   "public",            :default => "N"
    t.text     "note"
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "yml"
    t.text     "xml"
  end

  add_index "documents", ["person_id"], :name => "index_documents_on_person_id"

  create_table "exam_scores", :force => true do |t|
    t.integer  "exam_id"
    t.string   "subject"
    t.date     "taken_date"
    t.integer  "required_score"
    t.integer  "score"
    t.integer  "category_points_01"
    t.integer  "category_points_02"
    t.integer  "category_points_03"
    t.integer  "category_points_04"
    t.integer  "category_points_05"
    t.integer  "category_points_06"
    t.integer  "category_points_07"
    t.integer  "category_points_08"
    t.integer  "category_points_09"
    t.integer  "category_points_10"
    t.string   "status"
    t.text     "yml"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exam_scores", ["exam_id"], :name => "index_exam_scores_on_exam_id"

  create_table "exams", :force => true do |t|
    t.integer  "person_id"
    t.string   "report_number"
    t.date     "report_date"
    t.string   "status"
    t.string   "public",        :default => "Y"
    t.text     "note"
    t.text     "raw"
    t.text     "yml"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "dept"
  end

  add_index "exams", ["person_id"], :name => "index_exams_on_person_id"

  create_table "form_templates", :force => true do |t|
    t.string   "name"
    t.string   "category"
    t.string   "module"
    t.string   "academic_period"
    t.string   "path"
    t.integer  "sequence"
    t.boolean  "active",          :default => true
    t.string   "dept"
    t.text     "instruction"
    t.datetime "due_at"
    t.datetime "priority_due_at"
    t.datetime "deactivate_at"
    t.text     "yml"
    t.text     "xml"
    t.text     "note"
    t.string   "instruction_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forms", :force => true do |t|
    t.integer  "person_id"
    t.integer  "form_template_id"
    t.datetime "submitted_at"
    t.string   "submit_ip"
    t.text     "yml"
    t.string   "lock",             :default => "N"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "note"
    t.string   "public",           :default => "Y"
    t.string   "type"
    t.integer  "version"
    t.string   "academic_period"
    t.string   "dept"
  end

  add_index "forms", ["academic_period"], :name => "index_forms_on_academic_period"
  add_index "forms", ["type"], :name => "index_forms_on_type"

  create_table "menus", :force => true do |t|
    t.string  "name"
    t.string  "category"
    t.string  "module"
    t.string  "controller"
    t.string  "action"
    t.text    "params"
    t.integer "role_required", :default => 0
    t.integer "sequence"
    t.boolean "active"
    t.string  "dept"
    t.string  "context"
  end

  create_table "mercury_pages", :force => true do |t|
    t.string   "name",       :null => false
    t.text     "contents"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "mercury_pages", ["name"], :name => "index_mercury_pages_on_name", :unique => true

  create_table "pages", :force => true do |t|
    t.string   "name",       :null => false
    t.text     "contents"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["name"], :name => "index_pages_on_name", :unique => true

  create_table "persons", :force => true do |t|
    t.string   "ssn"
    t.string   "id_number"
    t.string   "ets_id"
    t.string   "uid"
    t.string   "email"
    t.string   "email_alt"
    t.string   "last_name"
    t.string   "first_name"
    t.string   "middle_initial"
    t.date     "birth_date"
    t.string   "ethnicity"
    t.string   "gender"
    t.string   "title"
    t.string   "source"
    t.string   "status",         :default => "N"
    t.text     "note"
    t.text     "ssn_crypted"
    t.string   "ssn_agreement"
    t.string   "other_name"
    t.text     "yml"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "persons", ["email"], :name => "index_persons_on_email"
  add_index "persons", ["id_number"], :name => "index_persons_on_id_number", :unique => true
  add_index "persons", ["status"], :name => "index_persons_on_status"

  create_table "practicum_assignments", :force => true do |t|
    t.integer  "practicum_placement_id"
    t.integer  "practicum_school_id"
    t.string   "assignment_type"
    t.integer  "person_id"
    t.string   "name"
    t.string   "content_area"
    t.string   "courses"
    t.integer  "payment"
    t.text     "yml"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "supervisor_primary_uid"
    t.string   "supervisor_secondary_uid"
    t.text     "note"
    t.integer  "user_primary_id"
    t.integer  "user_secondary_id"
  end

  add_index "practicum_assignments", ["assignment_type"], :name => "index_practicum_assignments_on_assignment_type"
  add_index "practicum_assignments", ["name"], :name => "index_practicum_assignments_on_name"
  add_index "practicum_assignments", ["person_id"], :name => "index_practicum_assignments_on_person_id"
  add_index "practicum_assignments", ["practicum_placement_id"], :name => "index_practicum_assignments_on_practicum_placement_id"
  add_index "practicum_assignments", ["practicum_school_id"], :name => "index_practicum_assignments_on_practicum_school_id"
  add_index "practicum_assignments", ["supervisor_primary_uid"], :name => "index_practicum_assignments_on_supervisor_primary_uid"
  add_index "practicum_assignments", ["supervisor_secondary_uid"], :name => "index_practicum_assignments_on_supervisor_secondary_uid"
  add_index "practicum_assignments", ["user_primary_id"], :name => "index_practicum_assignments_on_user_primary_id"
  add_index "practicum_assignments", ["user_secondary_id"], :name => "index_practicum_assignments_on_user_secondary_id"

  create_table "practicum_placements", :force => true do |t|
    t.integer  "practicum_profile_id"
    t.string   "academic_period"
    t.string   "status"
    t.string   "uid"
    t.string   "sequence"
    t.string   "category"
    t.string   "mentor_type"
    t.text     "note"
    t.string   "dept"
    t.text     "yml"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_primary_id"
    t.integer  "user_secondary_id"
  end

  add_index "practicum_placements", ["academic_period"], :name => "index_practicum_placements_on_academic_period"
  add_index "practicum_placements", ["practicum_profile_id"], :name => "index_practicum_placements_on_practicum_profile_id"
  add_index "practicum_placements", ["user_primary_id"], :name => "index_practicum_placements_on_user_primary_id"
  add_index "practicum_placements", ["user_secondary_id"], :name => "index_practicum_placements_on_user_secondary_id"

  create_table "practicum_profiles", :force => true do |t|
    t.integer  "person_id"
    t.integer  "curriculum_id"
    t.string   "bgc"
    t.date     "bgc_date"
    t.string   "insurance"
    t.string   "insurance_effective_period"
    t.text     "note"
    t.string   "dept"
    t.text     "yml"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "coordinator_primary_uid"
    t.string   "coordinator_secondary_uid"
    t.string   "group"
    t.string   "cohort"
  end

  add_index "practicum_profiles", ["coordinator_primary_uid"], :name => "index_practicum_profiles_on_coordinator_primary_uid"
  add_index "practicum_profiles", ["coordinator_secondary_uid"], :name => "index_practicum_profiles_on_coordinator_secondary_uid"
  add_index "practicum_profiles", ["curriculum_id"], :name => "index_practicum_profiles_on_curriculum_id"
  add_index "practicum_profiles", ["group"], :name => "index_practicum_profiles_on_group"
  add_index "practicum_profiles", ["person_id"], :name => "index_practicum_profiles_on_person_id"

  create_table "practicum_schools", :force => true do |t|
    t.string   "code"
    t.string   "island"
    t.string   "district"
    t.string   "grade_from"
    t.string   "grade_to"
    t.string   "school_type"
    t.string   "name"
    t.string   "name_short"
    t.string   "area"
    t.string   "area_group"
    t.string   "url_home"
    t.string   "status"
    t.text     "yml"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "practicum_schools", ["code"], :name => "index_practicum_schools_on_code"

  create_table "program_offers", :force => true do |t|
    t.integer  "program_id",                                  :null => false
    t.string   "distribution",                                :null => false
    t.string   "description"
    t.string   "description_short"
    t.string   "major"
    t.string   "academic_period"
    t.string   "available_major"
    t.string   "available_academic_period"
    t.integer  "sequence"
    t.boolean  "active",                    :default => true
    t.text     "yml"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "programs", :force => true do |t|
    t.string   "code",                                     :null => false
    t.string   "description"
    t.string   "description_short"
    t.string   "degree"
    t.string   "major"
    t.string   "track"
    t.string   "distribution"
    t.string   "location"
    t.string   "available_major"
    t.string   "available_track"
    t.string   "available_distribution"
    t.string   "available_location"
    t.string   "category"
    t.integer  "sequence"
    t.boolean  "active",                 :default => true
    t.string   "dept"
    t.text     "yml"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "programs", ["code"], :name => "index_programs_on_code"
  add_index "programs", ["degree"], :name => "index_programs_on_degree"

  create_table "properties", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.string   "description"
    t.string   "description_short"
    t.string   "category"
    t.string   "regexp"
    t.integer  "sequence"
    t.boolean  "active",            :default => true
    t.string   "dept"
    t.text     "yml"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "timestamps", :force => true do |t|
    t.integer  "user_id"
    t.string   "remote_ip"
    t.string   "controller"
    t.string   "action"
    t.datetime "created_at"
    t.string   "object_type"
    t.integer  "object_id"
    t.string   "path"
    t.string   "agent"
  end

  create_table "transition_actions", :force => true do |t|
    t.integer  "transition_point_id"
    t.string   "type"
    t.string   "action"
    t.string   "action_specify"
    t.date     "action_date"
    t.string   "note"
    t.integer  "sequence",            :default => 99
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "yml"
    t.text     "xml"
  end

  add_index "transition_actions", ["action"], :name => "index_transition_actions_on_action"
  add_index "transition_actions", ["transition_point_id"], :name => "index_transition_actions_on_transition_point_id"

  create_table "transition_points", :force => true do |t|
    t.integer  "curriculum_id",                            :null => false
    t.integer  "form_id"
    t.string   "academic_period",   :default => "0000000", :null => false
    t.string   "type",              :default => "",        :null => false
    t.string   "status"
    t.string   "category"
    t.string   "priority"
    t.integer  "user_primary_id"
    t.integer  "user_secondary_id"
    t.string   "dept"
    t.boolean  "active",            :default => false
    t.text     "note"
    t.text     "assessment_note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "yml"
    t.text     "xml"
    t.datetime "status_updated_at"
  end

  add_index "transition_points", ["academic_period"], :name => "index_transition_points_on_academic_period"
  add_index "transition_points", ["curriculum_id"], :name => "index_transition_points_on_curriculum_id"
  add_index "transition_points", ["dept"], :name => "index_transition_points_on_dept"
  add_index "transition_points", ["form_id"], :name => "index_transition_points_on_form_id"
  add_index "transition_points", ["status"], :name => "index_transition_points_on_status"
  add_index "transition_points", ["status_updated_at"], :name => "index_transition_points_on_status_updated_at"
  add_index "transition_points", ["type"], :name => "index_transition_points_on_type"

  create_table "users", :force => true do |t|
    t.string   "uid"
    t.string   "hashed_password"
    t.string   "dept"
    t.integer  "person_id"
    t.string   "category"
    t.string   "position"
    t.string   "department"
    t.integer  "emp_status",          :default => 0
    t.integer  "status",              :default => 0
    t.text     "yml"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "persistence_token",                  :null => false
    t.string   "single_access_token",                :null => false
    t.string   "perishable_token",                   :null => false
    t.integer  "login_count",         :default => 0, :null => false
    t.integer  "failed_login_count",  :default => 0, :null => false
  end

  add_index "users", ["person_id"], :name => "index_users_on_person_id"
  add_index "users", ["uid"], :name => "index_users_on_uid", :unique => true

end
