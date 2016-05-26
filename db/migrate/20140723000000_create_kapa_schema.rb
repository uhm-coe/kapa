class CreateKapaSchema < ActiveRecord::Migration
  def change

    create_table "advising_sessions", force: :cascade do |t|
      t.integer "person_id", limit: 4, null: false
      t.integer "curriculum_id", limit: 4
      t.integer "term_id", limit: 4
      t.string "type", limit: 255
      t.date "session_date"
      t.text "note", limit: 16777215
      t.string "task", limit: 255
      t.string "action", limit: 255
      t.string "specify", limit: 255
      t.string "current_field", limit: 255
      t.string "interest", limit: 255
      t.string "location", limit: 255
      t.string "category", limit: 255
      t.string "dept", limit: 255
      t.text "yml", limit: 16777215
      t.text "xml", limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "advising_sessions", ["curriculum_id"], name: "index_advising_sessions_on_curriculum_id", using: :btree
    add_index "advising_sessions", ["person_id"], name: "index_advisings_on_person_id", using: :btree
    add_index "advising_sessions", ["session_date"], name: "index_advisings_on_inquiry_date", using: :btree
    add_index "advising_sessions", ["task"], name: "index_advisings_on_task", using: :btree

    create_table "assessment_criterions", force: :cascade do |t|
      t.string "criterion", limit: 255
      t.text "criterion_desc", limit: 65535
      t.text "criterion_html", limit: 65535
      t.string "standard", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "assessment_rubric_id", limit: 4
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
      t.string "type", limit: 255, default: "default", null: false
      t.string "type_option", limit: 255
    end

    create_table "assessment_rubrics", force: :cascade do |t|
      t.integer "start_term_id", limit: 4
      t.integer "end_term_id", limit: 4
      t.string "title", limit: 255
      t.string "course", limit: 255
      t.string "reference_url", limit: 255
      t.string "dept", limit: 255
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "program", limit: 255
      t.string "assessment_type", limit: 255
      t.string "transition_point", limit: 255
    end

    add_index "assessment_rubrics", ["course"], name: "index_assessment_rubrics_on_course", using: :btree
    add_index "assessment_rubrics", ["end_term_id"], name: "index_assessment_rubrics_on_end_term_id", using: :btree
    add_index "assessment_rubrics", ["start_term_id"], name: "index_assessment_rubrics_on_start_term_id", using: :btree

    create_table "assessment_scores", force: :cascade do |t|
      t.string "assessment_scorable_type", limit: 255
      t.integer "assessment_scorable_id", limit: 4
      t.integer "assessment_criterion_id", limit: 4
      t.string "rating", limit: 255
      t.string "rated_by", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
    end

    add_index "assessment_scores", ["assessment_scorable_type", "assessment_scorable_id", "assessment_criterion_id"], name: "index_assessment_scores_on_scorable_and_criterion_id", unique: true, using: :btree

    create_table "course_registrations", force: :cascade do |t|
      t.integer "course_id", limit: 4
      t.integer "person_id", limit: 4
      t.string "status", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
    end

    add_index "course_registrations", ["course_id", "person_id"], name: "index_assessment_course_registrations_on_course_id_and_person_id", unique: true, using: :btree

    create_table "courses", force: :cascade do |t|
      t.string "crn", limit: 150
      t.string "subject", limit: 255
      t.string "number", limit: 255
      t.string "section", limit: 255
      t.string "title", limit: 255
      t.string "instructor", limit: 255
      t.integer "credits", limit: 4
      t.string "status", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
      t.string "dept", limit: 255
      t.integer "term_id", limit: 4
      t.integer "credits", limit: 4
    end

    add_index "courses", ["term_id", "crn"], name: "index_courses_on_term_id_and_crn", unique: true, using: :btree
    add_index "courses", ["term_id"], name: "index_courses_on_term_id", using: :btree

    create_table "curriculums", force: :cascade do |t|
      t.integer "person_id", limit: 4, null: false
      t.integer "program_id", limit: 4, null: false
      t.integer "term_id", limit: 4
      t.string "second_degree", limit: 255
      t.string "major_primary", limit: 255
      t.string "major_secondary", limit: 255
      t.string "track", limit: 255
      t.string "distribution", limit: 255
      t.string "location", limit: 255
      t.string "cohort", limit: 255
      t.string "status", limit: 255
      t.boolean "active", default: false
      t.string "dept", limit: 255
      t.text "note", limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
    end

    add_index "curriculums", ["dept"], name: "index_curriculums_on_dept", using: :btree
    add_index "curriculums", ["person_id"], name: "index_curriculums_on_person_id", using: :btree
    add_index "curriculums", ["program_id"], name: "index_curriculums_on_program_id", using: :btree

    create_table "datasets", force: :cascade do |t|
      t.string "name", limit: 255
      t.string "description", limit: 255
      t.string "type", limit: 255
      t.string "category", limit: 255
      t.string "datasource", limit: 255
      t.text "query", limit: 65535
      t.string "ldap_base", limit: 255
      t.string "ldap_filter", limit: 255
      t.text "ldap_attr", limit: 65535
      t.integer "record_count", limit: 4
      t.datetime "loaded_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
    end

    create_table "enrollments", force: :cascade do |t|
      t.integer "curriculum_id", limit: 4
      t.integer "term_id", limit: 4
      t.string "sequence", limit: 255
      t.string "category", limit: 255
      t.string "status", limit: 255
      t.text "note", limit: 65535
      t.string "dept", limit: 255
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "enrollments", ["curriculum_id"], name: "index_enrollments_on_curriculum_id", using: :btree
    add_index "enrollments", ["term_id"], name: "index_enrollments_on_term_id", using: :btree

    create_table "exam_scores", force: :cascade do |t|
      t.integer "exam_id", limit: 4
      t.string "subject", limit: 255
      t.date "taken_date"
      t.integer "required_score", limit: 4
      t.integer "score", limit: 4
      t.integer "category_points_01", limit: 4
      t.integer "category_points_02", limit: 4
      t.integer "category_points_03", limit: 4
      t.integer "category_points_04", limit: 4
      t.integer "category_points_05", limit: 4
      t.integer "category_points_06", limit: 4
      t.integer "category_points_07", limit: 4
      t.integer "category_points_08", limit: 4
      t.integer "category_points_09", limit: 4
      t.integer "category_points_10", limit: 4
      t.string "status", limit: 255
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "exam_scores", ["exam_id"], name: "index_exam_scores_on_exam_id", using: :btree

    create_table "exams", force: :cascade do |t|
      t.integer "person_id", limit: 4
      t.integer "attachable_id", limit: 4
      t.string "attachable_type", limit: 255
      t.string "report_number", limit: 255
      t.date "report_date"
      t.string "status", limit: 255
      t.string "public", limit: 255, default: "Y"
      t.text "note", limit: 65535
      t.text "raw", limit: 65535
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "dept", limit: 255
      t.string "type", limit: 255
    end

    create_table "faculty_awards", force: :cascade do |t|
      t.integer "person_id"
      t.string "dept", limit: 255
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
      t.string "name", limit: 255
      t.date "award_date"
      t.string "affiliation", limit: 255
      t.text "description", limit: 65535
      t.string "url", limit: 255
      t.string "context", limit: 255
      t.integer "faculty_service_activity_id"
      t.string "public", limit: 255, default: "Y"
      t.string "image_file_name", limit: 255
      t.string "image_content_type", limit: 255
      t.integer "image_file_size", limit: 4
      t.datetime "image_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "faculty_publications", force: :cascade do |t|
      t.integer "person_id"
      t.string "dept"
      t.string "type", limit: 255
      t.text "abstract"
      t.string "pages", limit: 255
      t.string "published_date", limit: 255
      t.string "location", limit: 255
      t.string "publisher", limit: 255
      t.text "keyword"
      t.string "venue", limit: 255
      t.string "vol", limit: 255
      t.string "num_of_vol", limit: 255
      t.string "creator", limit: 255
      t.string "title", limit: 255
      t.string "month", limit: 255
      t.string "year", limit: 255
      t.string "document_identifier", limit: 255
      t.string "editor", limit: 255
      t.string "book_title", limit: 255
      t.string "book_chapter", limit: 255
      t.string "organization", limit: 255
      t.string "edition", limit: 255
      t.string "institution", limit: 255 # institution
      t.string "research_location", limit: 255 # research location
      t.string "document_location", limit: 255
      t.boolean "featured"
      t.string "thumbnail_file_name", limit: 255
      t.string "thumbnail_content_type", limit: 255
      t.integer "thumbnail_file_size", limit: 4
      t.datetime "thumbnail_updated_at"
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "faculty_publication_authors", force: :cascade do |t|
      t.integer "faculty_publication_id"
      t.string "type", limit: 255
      t.integer "person_id", null: true
      t.string "last_name", limit: 255
      t.string "first_name", limit: 255
      t.string "middle_initial", limit: 255
      t.integer "sequence"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
    end

    add_index "faculty_publication_authors", ["faculty_publication_id"], name: "index_authors_on_faculty_publication_id", using: :btree

    create_table "faculty_service_activities", force: :cascade do |t|
      t.integer "person_id"
      t.string "dept", limit: 255
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
      t.string "service_type", limit: 255
      t.date "service_date_start"
      t.date "service_date_end"
      t.string "affiliation", limit: 255
      t.text "role", limit: 65535
      t.string "name", limit: 255
      t.string "compensation", limit: 255
      t.boolean "relevant", default: true
      t.string "context", limit: 255
      t.text "description", limit: 65535
      t.string "public", limit: 255, default: "Y"

      t.string "image_file_name", limit: 255
      t.string "image_content_type", limit: 255
      t.integer "image_file_size", limit: 4
      t.datetime "image_updated_at"

      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "exams", ["person_id"], name: "index_exams_on_person_id", using: :btree

    create_table "files", force: :cascade do |t|
      t.integer "person_id", limit: 4
      t.integer "attachable_id", limit: 4
      t.string "attachable_type", limit: 255
      t.string "name", limit: 255
      t.string "type", limit: 255
      t.string "status", limit: 255
      t.string "uploaded_by", limit: 255
      t.string "dept", limit: 255
      t.string "public", limit: 255, default: "N"
      t.text "note", limit: 65535
      t.string "data_file_name", limit: 255
      t.string "data_content_type", limit: 255
      t.integer "data_file_size", limit: 4
      t.datetime "data_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
    end

    add_index "files", ["person_id"], name: "index_files_on_person_id", using: :btree

    create_table "forms", force: :cascade do |t|
      t.string "type", limit: 255
      t.integer "person_id", limit: 4
      t.integer "term_id", limit: 4
      t.integer "attachable_id", limit: 4
      t.string "attachable_type", limit: 255
      t.datetime "submitted_at"
      t.string "submit_ip", limit: 255
      t.string "lock", limit: 255, default: "N"
      t.text "note", limit: 16777215
      t.string "public", limit: 255, default: "Y"
      t.integer "version", limit: 4
      t.string "dept", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "yml", limit: 16777215
      t.text "xml", limit: 16777215
    end

    add_index "forms", ["person_id"], name: "index_forms_on_person_id", using: :btree
    add_index "forms", ["term_id"], name: "index_forms_on_term_id", using: :btree
    add_index "forms", ["type"], name: "index_forms_on_type", using: :btree

    create_table "persons", force: :cascade do |t|
      t.string "id_number", limit: 255
      t.string "ets_id", limit: 255
      t.string "uid", limit: 255
      t.string "type", limit: 255
      t.string "last_name", limit: 255
      t.string "first_name", limit: 255
      t.string "middle_initial", limit: 255
      t.string "other_name", limit: 255
      t.string "title", limit: 255
      t.date "birth_date"
      t.string "ethnicity", limit: 255
      t.string "gender", limit: 255
      t.string "ssn", limit: 255
      t.text "ssn_crypted", limit: 16777215
      t.string "ssn_agreement", limit: 255
      t.string "email", limit: 255
      t.string "email_alt", limit: 255
      t.string "cur_phone", limit: 255
      t.string "per_phone", limit: 255
      t.string "business_phone", limit: 255
      t.string "mobile_phone", limit: 255
      t.string "cur_street", limit: 255
      t.string "cur_city", limit: 255
      t.string "cur_state", limit: 255
      t.string "cur_postal_code", limit: 255
      t.string "per_street", limit: 255
      t.string "per_city", limit: 255
      t.string "per_state", limit: 255
      t.string "per_postal_code", limit: 255
      t.string "fax", limit: 255
      t.string "source", limit: 255
      t.string "status", limit: 255, default: "N"
      t.text "note", limit: 16777215
      t.string "dept", limit: 255
      t.text "yml", limit: 16777215
      t.text "xml", limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "persons", ["email"], name: "index_persons_on_email", using: :btree
    add_index "persons", ["id_number"], name: "index_persons_on_id_number", unique: true, using: :btree
    add_index "persons", ["status"], name: "index_persons_on_status", using: :btree

    create_table "practicum_logs", force: :cascade do |t|
      t.integer "practicum_placement_id", limit: 4
      t.date "log_date"
      t.string "type", limit: 255
      t.string "category", limit: 255
      t.string "task", limit: 255
      t.string "status", limit: 255
      t.integer "length", limit: 4
      t.integer "user_id", limit: 4
      t.text "note", limit: 65535
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "practicum_placements", force: :cascade do |t|
      t.integer "person_id", limit: 4
      t.integer "start_term_id", limit: 4
      t.integer "end_term_id", limit: 4
      t.integer "curriculum_id", limit: 4
      t.integer "practicum_site_id", limit: 4
      t.integer "mentor_person_id", limit: 4
      t.text "note", limit: 65535
      t.string "type", limit: 255
      t.string "category", limit: 255
      t.string "status", limit: 255
      t.string "dept", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
    end

    add_index "practicum_placements", ["curriculum_id"], name: "index_practicum_placements_on_curriculum_id", using: :btree
    add_index "practicum_placements", ["end_term_id"], name: "index_practicum_placements_on_end_term_id", using: :btree
    add_index "practicum_placements", ["mentor_person_id"], name: "index_practicum_placements_on_mentor_person_id", using: :btree
    add_index "practicum_placements", ["person_id"], name: "index_practicum_placements_on_person_id", using: :btree
    add_index "practicum_placements", ["practicum_site_id"], name: "index_practicum_placements_on_practicum_site_id", using: :btree
    add_index "practicum_placements", ["start_term_id"], name: "index_practicum_placements_on_start_term_id", using: :btree

    create_table "practicum_sites", force: :cascade do |t|
      t.string "code", limit: 255
      t.string "name", limit: 255
      t.string "name_short", limit: 255
      t.string "level_from", limit: 255
      t.string "level_to", limit: 255
      t.string "url", limit: 255
      t.string "district", limit: 255
      t.string "area", limit: 255
      t.string "area_group", limit: 255
      t.string "category", limit: 255
      t.string "status", limit: 255
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "practicum_sites", ["code"], name: "index_practicum_sites_on_code", using: :btree

    create_table "program_offers", force: :cascade do |t|
      t.integer "program_id", limit: 4, null: false
      t.integer "start_term_id", limit: 4
      t.integer "end_term_id", limit: 4
      t.string "description", limit: 255
      t.string "description_short", limit: 255
      t.string "major", limit: 255
      t.string "available_major", limit: 255
      t.string "distribution", limit: 255
      t.string "available_distribution", limit: 255
      t.integer "sequence", limit: 4
      t.boolean "active", default: true
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "program_offers", ["end_term_id"], name: "index_program_offers_on_end_term_id", using: :btree
    add_index "program_offers", ["start_term_id"], name: "index_program_offers_on_start_term_id", using: :btree

    create_table "programs", force: :cascade do |t|
      t.string "code", limit: 255, null: false
      t.string "description", limit: 255
      t.string "description_short", limit: 255
      t.string "degree", limit: 255
      t.string "major", limit: 255
      t.string "track", limit: 255
      t.string "distribution", limit: 255
      t.string "location", limit: 255
      t.string "available_major", limit: 255
      t.string "available_track", limit: 255
      t.string "available_distribution", limit: 255
      t.string "available_location", limit: 255
      t.string "category", limit: 255
      t.integer "sequence", limit: 4
      t.boolean "active", default: true
      t.string "dept", limit: 255
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "programs", ["code"], name: "index_programs_on_code", using: :btree
    add_index "programs", ["degree"], name: "index_programs_on_degree", using: :btree

    create_table "properties", force: :cascade do |t|
      t.string "name", limit: 255
      t.string "code", limit: 255
      t.string "description", limit: 255
      t.string "description_short", limit: 255
      t.string "category", limit: 255
      t.string "regexp", limit: 255
      t.integer "sequence", limit: 4
      t.boolean "active", default: true
      t.string "dept", limit: 255
      t.text "yml", limit: 16777215
      t.text "xml", limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "properties", ["name", "code"], name: "index_properties_on_name_and_code", unique: true, using: :btree

    create_table "sessions", force: :cascade do |t|
      t.string "session_id", limit: 255, null: false
      t.text "data", limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
    add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

    create_table "terms", force: :cascade do |t|
      t.string "code", limit: 255
      t.string "description", limit: 255
      t.string "description_short", limit: 255
      t.date "start_date"
      t.date "end_date"
      t.integer "sequence", limit: 4
      t.string "academic_year", limit: 255
      t.string "calendar_year", limit: 255
      t.string "fiscal_year", limit: 255
      t.boolean "regular_term"
      t.boolean "active", default: true
      t.string "dept", limit: 255
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "timestamps", force: :cascade do |t|
      t.integer "user_id", limit: 4
      t.string "path", limit: 255
      t.string "remote_ip", limit: 255
      t.string "agent", limit: 255
      t.datetime "created_at"
    end

    create_table "transition_actions", force: :cascade do |t|
      t.integer "transition_point_id", limit: 4
      t.string "type", limit: 255
      t.string "action", limit: 255
      t.string "action_specify", limit: 255
      t.date "action_date"
      t.string "note", limit: 255
      t.integer "sequence", limit: 4, default: 99
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
    end

    add_index "transition_actions", ["action"], name: "index_transition_actions_on_action", using: :btree
    add_index "transition_actions", ["transition_point_id"], name: "index_transition_actions_on_transition_point_id", using: :btree

    create_table "transition_points", force: :cascade do |t|
      t.integer "curriculum_id", limit: 4, null: false
      t.integer "form_id", limit: 4
      t.integer "term_id", limit: 4
      t.string "type", limit: 255, default: "", null: false
      t.string "status", limit: 255
      t.string "category", limit: 255
      t.string "priority", limit: 255
      t.integer "user_primary_id", limit: 4
      t.integer "user_secondary_id", limit: 4
      t.string "dept", limit: 255
      t.boolean "active", default: false
      t.text "note", limit: 65535
      t.text "assessment_note", limit: 65535
      t.datetime "status_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
    end

    add_index "transition_points", ["curriculum_id"], name: "index_transition_points_on_curriculum_id", using: :btree
    add_index "transition_points", ["term_id"], name: "index_transition_points_on_term_id", using: :btree
    add_index "transition_points", ["dept"], name: "index_transition_points_on_dept", using: :btree
    add_index "transition_points", ["form_id"], name: "index_transition_points_on_form_id", using: :btree
    add_index "transition_points", ["status"], name: "index_transition_points_on_status", using: :btree
    add_index "transition_points", ["status_updated_at"], name: "index_transition_points_on_status_updated_at", using: :btree
    add_index "transition_points", ["type"], name: "index_transition_points_on_type", using: :btree

    create_table "user_assignments", force: :cascade do |t|
      t.integer "user_id", limit: 4
      t.integer "assignable_id", limit: 4
      t.string "assignable_type", limit: 255
      t.string "task", limit: 255
      t.datetime "due_at"
      t.text "yml", limit: 16777215
      t.text "xml", limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "user_assignments", ["user_id", "assignable_id", "assignable_type"], name: "index_user_assignments_on_user_id_and_assignable_id", using: :btree

    create_table "users", force: :cascade do |t|
      t.string "uid", limit: 255
      t.string "hashed_password", limit: 255
      t.string "dept", limit: 255
      t.string "primary_dept", limit: 255
      t.integer "person_id", limit: 4
      t.string "category", limit: 255
      t.string "position", limit: 255
      t.integer "status", limit: 4, default: 0
      t.text "yml", limit: 16777215
      t.text "xml", limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "persistence_token", limit: 255, null: false
      t.string "single_access_token", limit: 255, null: false
      t.string "perishable_token", limit: 255, null: false
      t.integer "login_count", limit: 4, default: 0, null: false
      t.integer "login_count", limit: 4, default: 0, null: false
      t.integer "failed_login_count", limit: 4, default: 0, null: false
    end

    add_index "users", ["person_id"], name: "index_users_on_person_id", using: :btree
    add_index "users", ["uid"], name: "index_users_on_uid", unique: true, using: :btree

    create_table "case_actions", force: :cascade do |t|
      t.integer "case_id", limit: 4
      t.integer "person_id", limit: 4
      t.string "type", limit: 255
      t.string "action", limit: 255
      t.string "action_specify", limit: 255
      t.date "action_date"
      t.string "note", limit: 255
      t.integer "sequence", limit: 4, default: 99
      t.integer "user_id", limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
    end

    add_index "case_actions", ["action"]
    add_index "case_actions", ["case_id"]

    create_table "cases", force: :cascade do |t|
      t.string "type", limit: 255, default: "", null: false
      t.string "case_number_alt", limit: 255
      t.string "case_name", limit: 255
      t.string "status", limit: 255
      t.string "category", limit: 255
      t.string "priority", limit: 255
      t.string "location", limit: 255
      t.string "location_detail", limit: 255
      t.datetime "incident_occurred_at"
      t.string "referrer", limit: 255
      t.string "dept", limit: 255
      t.boolean "active", default: true
      t.text "note", limit: 65535
      t.datetime "reported_at"
      t.datetime "closed_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "status_updated_at"
      t.text "yml", limit: 65535
      t.text "xml", limit: 65535
    end

    add_index "cases", ["dept"]
    add_index "cases", ["status"]
    add_index "cases", ["type"]

    create_table "case_involvements", force: :cascade do |t|
      t.integer "case_id"
      t.integer "person_id", limit: 4
      t.string "type", limit: 255
      t.string "affiliation", limit: 255
      t.string "bargaining_unit", limit: 255
      t.string "job_title", limit: 255
      t.string "category", limit: 255
      t.string "status", limit: 255
      t.integer "sequence"
      t.text "note", limit: 16777215
      t.text "yml", limit: 16777215
      t.text "xml", limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "case_involvements", ["person_id", "case_id"], name: "index_case_involvements_on_person_id_and_case_id", using: :btree

    create_table "case_communications", force: :cascade do |t|
      t.integer "case_id"
      t.integer "person_id", limit: 4
      t.datetime "contacted_at"
      t.string "type", limit: 255
      t.string "category", limit: 255
      t.string "status", limit: 255
      t.integer "sequence"
      t.text "note", limit: 16777215
      t.text "yml", limit: 16777215
      t.text "xml", limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "case_communications", ["person_id", "case_id"], name: "index_case_communications_on_person_id_and_case_id", using: :btree
  end
end
