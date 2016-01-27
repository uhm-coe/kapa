class CreateKapaSchema < ActiveRecord::Migration
  def up

    create_table "advising_sessions", force: :cascade do |t|
      t.integer  "person_id",                limit: 4,        null: false
      t.date     "session_date"
      t.string   "session_type",             limit: 255
      t.text     "note",                     limit: 16777215
      t.string   "task",                     limit: 255
      t.string   "action",                   limit: 255
      t.string   "specify",                  limit: 255
      t.string   "classification",           limit: 255
      t.string   "current_field",            limit: 255
      t.string   "interest",                 limit: 255
      t.string   "location",                 limit: 255
      t.string   "handled_by",               limit: 255
      t.string   "first_name",               limit: 255
      t.string   "last_name",                limit: 255
      t.string   "email",                    limit: 255
      t.string   "mail_address",             limit: 255
      t.string   "phone",                    limit: 255
      t.string   "identity_note",            limit: 255
      t.string   "contact_note",             limit: 255
      t.string   "dept",                     limit: 255
      t.integer  "curriculum_enrollment_id", limit: 4
      t.text     "yml",                      limit: 16777215
      t.text     "xml",                      limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "curriculum_id",            limit: 4
      t.integer  "user_primary_id",          limit: 4
      t.integer  "user_secondary_id",        limit: 4
    end

    add_index "advising_sessions", ["curriculum_id"], name: "index_advising_sessions_on_curriculum_id", using: :btree
    add_index "advising_sessions", ["handled_by"], name: "index_advisings_on_handled_by", using: :btree
    add_index "advising_sessions", ["person_id"], name: "index_advisings_on_person_id", using: :btree
    add_index "advising_sessions", ["session_date"], name: "index_advisings_on_inquiry_date", using: :btree
    add_index "advising_sessions", ["task"], name: "index_advisings_on_task", using: :btree

    create_table "assessment_criterions", force: :cascade do |t|
      t.string   "criterion",            limit: 255
      t.text     "criterion_desc",       limit: 65535
      t.text     "criterion_html",       limit: 65535
      t.string   "standard",             limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "assessment_rubric_id", limit: 4
      t.text     "yml",                  limit: 65535
      t.text     "xml",                  limit: 65535
      t.string   "type",                 limit: 255,   default: "default", null: false
      t.string   "type_option",          limit: 255
    end

    create_table "assessment_rubrics", force: :cascade do |t|
      t.string   "title",                 limit: 255
      t.string   "course",                limit: 255
      t.string   "reference_url",         limit: 255
      t.string   "dept",                  limit: 255
      t.text     "yml",                   limit: 65535
      t.text     "xml",                   limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "program",               limit: 255
      t.string   "assessment_type",       limit: 255
      t.string   "transition_point",      limit: 255
      t.string   "academic_period_start", limit: 255,   default: "200010"
      t.string   "academic_period_end",   limit: 255,   default: "999999"
      t.integer  "start_term_id",         limit: 4
      t.integer  "end_term_id",           limit: 4
    end

    add_index "assessment_rubrics", ["academic_period_end"], name: "index_assessment_rubrics_on_academic_period_end", using: :btree
    add_index "assessment_rubrics", ["academic_period_start"], name: "index_assessment_rubrics_on_academic_period_start", using: :btree
    add_index "assessment_rubrics", ["course"], name: "index_assessment_rubrics_on_course", using: :btree
    add_index "assessment_rubrics", ["end_term_id"], name: "index_assessment_rubrics_on_end_term_id", using: :btree
    add_index "assessment_rubrics", ["start_term_id"], name: "index_assessment_rubrics_on_start_term_id", using: :btree

    create_table "assessment_scores", force: :cascade do |t|
      t.integer  "assessment_scorable_id",   limit: 4
      t.integer  "assessment_criterion_id",  limit: 4
      t.string   "rating",                   limit: 255
      t.string   "rated_by",                 limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "yml",                      limit: 65535
      t.text     "xml",                      limit: 65535
      t.string   "assessment_scorable_type", limit: 255
      t.string   "academic_period",          limit: 255
      t.integer  "user_id",                  limit: 4
    end

    add_index "assessment_scores", ["assessment_scorable_type", "assessment_scorable_id", "assessment_criterion_id"], name: "index_assessment_scores_on_scorable_and_criterion_id", unique: true, using: :btree

    create_table "contacts", force: :cascade do |t|
      t.integer  "entity_id",       limit: 4,        null: false
      t.string   "entity_type",     limit: 255
      t.string   "cur_street",      limit: 255
      t.string   "cur_city",        limit: 255
      t.string   "cur_state",       limit: 255
      t.string   "cur_postal_code", limit: 255
      t.string   "per_street",      limit: 255
      t.string   "per_city",        limit: 255
      t.string   "per_state",       limit: 255
      t.string   "per_postal_code", limit: 255
      t.string   "cur_phone",       limit: 255
      t.string   "per_phone",       limit: 255
      t.string   "business_phone",  limit: 255
      t.string   "mobile_phone",    limit: 255
      t.string   "fax",             limit: 255
      t.string   "email",           limit: 255
      t.string   "note",            limit: 255
      t.text     "yml",             limit: 16777215
      t.text     "xml",             limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "contacts", ["entity_id"], name: "index_contacts_on_entity_id", using: :btree

    create_table "course_registrations", force: :cascade do |t|
      t.integer  "course_id",  limit: 4
      t.integer  "person_id",  limit: 4
      t.string   "status",     limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "yml",        limit: 65535
      t.text     "xml",        limit: 65535
    end

    add_index "course_registrations", ["course_id", "person_id"], name: "index_assessment_course_registrations_on_course_id_and_person_id", unique: true, using: :btree

    create_table "courses", force: :cascade do |t|
      t.string   "academic_period", limit: 150
      t.string   "crn",             limit: 150
      t.string   "subject",         limit: 255
      t.string   "number",          limit: 255
      t.string   "section",         limit: 255
      t.string   "title",           limit: 255
      t.string   "instructor",      limit: 255
      t.string   "status",          limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "yml",             limit: 65535
      t.text     "xml",             limit: 65535
      t.string   "final_grade",     limit: 255
      t.string   "dept",            limit: 255
      t.integer  "user_id",         limit: 4
      t.integer  "term_id",         limit: 4
    end

    add_index "courses", ["academic_period", "crn"], name: "index_courses_on_academic_period_and_crn", unique: true, using: :btree
    add_index "courses", ["term_id"], name: "index_courses_on_term_id", using: :btree

    create_table "curriculums", force: :cascade do |t|
      t.integer  "person_id",         limit: 4,                        null: false
      t.integer  "program_id",        limit: 4,                        null: false
      t.string   "academic_period",   limit: 255,   default: "000000", null: false
      t.string   "second_degree",     limit: 255
      t.string   "major_primary",     limit: 255
      t.string   "major_secondary",   limit: 255
      t.string   "track",             limit: 255
      t.string   "distribution",      limit: 255
      t.string   "location",          limit: 255
      t.string   "cohort",            limit: 255
      t.string   "status",            limit: 255
      t.string   "dept",              limit: 255
      t.integer  "user_primary_id",   limit: 4
      t.integer  "user_secondary_id", limit: 4
      t.boolean  "active",                          default: false
      t.text     "note",              limit: 65535
      t.text     "yml",               limit: 65535
      t.text     "xml",               limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "curriculums", ["academic_period"], name: "index_curriculums_on_academic_period", using: :btree
    add_index "curriculums", ["dept"], name: "index_curriculums_on_dept", using: :btree
    add_index "curriculums", ["person_id"], name: "index_curriculums_on_person_id", using: :btree
    add_index "curriculums", ["program_id"], name: "index_curriculums_on_program_id", using: :btree
    add_index "curriculums", ["user_primary_id"], name: "index_curriculums_on_user_primary_id", using: :btree
    add_index "curriculums", ["user_secondary_id"], name: "index_curriculums_on_user_secondary_id", using: :btree

    create_table "datasets", force: :cascade do |t|
      t.string   "name",         limit: 255
      t.string   "description",  limit: 255
      t.string   "type",         limit: 255
      t.string   "category",     limit: 255
      t.string   "datasource",   limit: 255
      t.text     "query",        limit: 65535
      t.string   "ldap_base",    limit: 255
      t.string   "ldap_filter",  limit: 255
      t.text     "ldap_attr",    limit: 65535
      t.integer  "record_count", limit: 4
      t.datetime "loaded_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "yml",          limit: 65535
      t.text     "xml",          limit: 65535
    end

    create_table "enrollments", force: :cascade do |t|
      t.integer  "curriculum_id",     limit: 4
      t.integer  "term_id",           limit: 4
      t.string   "sequence",          limit: 255
      t.string   "category",          limit: 255
      t.string   "status",            limit: 255
      t.text     "note",              limit: 65535
      t.string   "dept",              limit: 255
      t.integer  "user_primary_id",   limit: 4
      t.integer  "user_secondary_id", limit: 4
      t.text     "yml",               limit: 65535
      t.text     "xml",               limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "enrollments", ["curriculum_id"], name: "index_enrollments_on_curriculum_id", using: :btree
    add_index "enrollments", ["term_id"], name: "index_enrollments_on_term_id", using: :btree
    add_index "enrollments", ["user_primary_id"], name: "index_enrollments_on_user_primary_id", using: :btree
    add_index "enrollments", ["user_secondary_id"], name: "index_enrollments_on_user_secondary_id", using: :btree

    create_table "exam_scores", force: :cascade do |t|
      t.integer  "exam_id",            limit: 4
      t.string   "subject",            limit: 255
      t.date     "taken_date"
      t.integer  "required_score",     limit: 4
      t.integer  "score",              limit: 4
      t.integer  "category_points_01", limit: 4
      t.integer  "category_points_02", limit: 4
      t.integer  "category_points_03", limit: 4
      t.integer  "category_points_04", limit: 4
      t.integer  "category_points_05", limit: 4
      t.integer  "category_points_06", limit: 4
      t.integer  "category_points_07", limit: 4
      t.integer  "category_points_08", limit: 4
      t.integer  "category_points_09", limit: 4
      t.integer  "category_points_10", limit: 4
      t.string   "status",             limit: 255
      t.text     "yml",                limit: 65535
      t.text     "xml",                limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "exam_scores", ["exam_id"], name: "index_exam_scores_on_exam_id", using: :btree

    create_table "exams", force: :cascade do |t|
      t.integer  "person_id",     limit: 4
      t.string   "report_number", limit: 255
      t.date     "report_date"
      t.string   "status",        limit: 255
      t.string   "public",        limit: 255,   default: "Y"
      t.text     "note",          limit: 65535
      t.text     "raw",           limit: 65535
      t.text     "yml",           limit: 65535
      t.text     "xml",           limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "dept",          limit: 255
      t.string   "type",          limit: 255
    end

    add_index "exams", ["person_id"], name: "index_exams_on_person_id", using: :btree

    create_table "files", force: :cascade do |t|
      t.integer  "person_id",         limit: 4,                   null: false
      t.string   "name",              limit: 255
      t.string   "type",              limit: 255
      t.string   "status",            limit: 255
      t.string   "uploaded_by",       limit: 255
      t.string   "dept",              limit: 255
      t.string   "public",            limit: 255,   default: "N"
      t.text     "note",              limit: 65535
      t.string   "data_file_name",    limit: 255
      t.string   "data_content_type", limit: 255
      t.integer  "data_file_size",    limit: 4
      t.datetime "data_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "yml",               limit: 65535
      t.text     "xml",               limit: 65535
    end

    add_index "files", ["person_id"], name: "index_files_on_person_id", using: :btree

    create_table "forms", force: :cascade do |t|
      t.integer  "person_id",        limit: 4
      t.integer  "form_template_id", limit: 4
      t.datetime "submitted_at"
      t.string   "submit_ip",        limit: 255
      t.text     "yml",              limit: 16777215
      t.string   "lock",             limit: 255,      default: "N"
      t.text     "xml",              limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "note",             limit: 16777215
      t.string   "public",           limit: 255,      default: "Y"
      t.string   "type",             limit: 255
      t.integer  "version",          limit: 4
      t.string   "academic_period",  limit: 255
      t.string   "dept",             limit: 255
      t.integer  "term_id",          limit: 4
    end

    add_index "forms", ["academic_period"], name: "index_forms_on_academic_period", using: :btree
    add_index "forms", ["term_id"], name: "index_forms_on_term_id", using: :btree
    add_index "forms", ["type"], name: "index_forms_on_type", using: :btree

    create_table "persons", force: :cascade do |t|
      t.string   "ssn",            limit: 255
      t.string   "id_number",      limit: 255
      t.string   "ets_id",         limit: 255
      t.string   "uid",            limit: 255
      t.string   "email",          limit: 255
      t.string   "email_alt",      limit: 255
      t.string   "last_name",      limit: 255
      t.string   "first_name",     limit: 255
      t.string   "middle_initial", limit: 255
      t.date     "birth_date"
      t.string   "ethnicity",      limit: 255
      t.string   "gender",         limit: 255
      t.string   "title",          limit: 255
      t.string   "source",         limit: 255
      t.string   "status",         limit: 255,      default: "N"
      t.text     "note",           limit: 16777215
      t.text     "ssn_crypted",    limit: 16777215
      t.string   "ssn_agreement",  limit: 255
      t.string   "other_name",     limit: 255
      t.text     "yml",            limit: 16777215
      t.text     "xml",            limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "persons", ["email"], name: "index_persons_on_email", using: :btree
    add_index "persons", ["id_number"], name: "index_persons_on_id_number", unique: true, using: :btree
    add_index "persons", ["status"], name: "index_persons_on_status", using: :btree

    create_table :publications, force: :cascade  do |t|
        t.integer "person_id"
        t.string "dept"
        t.string "authors"
        t.string "dn",                 limit: 255
        t.string "objectclass",        limit: 255
        t.string "ou",                 limit: 255
        t.string "pubpages",           limit: 255
        t.text "pubabstract"
        t.string "pubdate",            limit: 255
        t.string "publocation",        limit: 255
        t.text "pubowner"
        t.string "pubpublisher",       limit: 255
        t.text "documentauthor"
        t.string "pubtype",            limit: 255
        t.string "cn",                 limit: 255
        t.text "pubkeyword"
        t.string "pubvenue",           limit: 255
        t.string "pubvol",             limit: 255
        t.string "pubcreator",         limit: 255
        t.string "pubtitle",           limit: 255
        t.string "pubmonth",           limit: 255
        t.string "pubyear",            limit: 255
        t.string "documentidentifier", limit: 255
        t.text "pubcontributor"
        t.string "pubeditor",          limit: 255
        t.string "pubbooktitle",       limit: 255
        t.string "pubthumbnail",       limit: 255
        t.string "pubbookchapter",     limit: 255
        t.string "pubisnotfeatured",   limit: 255
        t.string "puborganization",    limit: 255
        t.string "pubpdf",             limit: 255
        t.string "pubedition",         limit: 255
        t.string "o",                  limit: 255
        t.string "l",                  limit: 255
        t.string "documentlocation",   limit: 255
    end

    create_table "practicum_assignments_old", force: :cascade do |t|
      t.integer  "practicum_placement_id",   limit: 4
      t.integer  "practicum_school_id",      limit: 4
      t.string   "assignment_type",          limit: 255
      t.integer  "person_id",                limit: 4
      t.string   "name",                     limit: 255
      t.string   "content_area",             limit: 255
      t.string   "courses",                  limit: 255
      t.integer  "payment",                  limit: 4
      t.text     "yml",                      limit: 65535
      t.text     "xml",                      limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "supervisor_primary_uid",   limit: 255
      t.string   "supervisor_secondary_uid", limit: 255
      t.text     "note",                     limit: 65535
      t.integer  "user_primary_id",          limit: 4
      t.integer  "user_secondary_id",        limit: 4
      t.string   "grade",                    limit: 255
    end

    add_index "practicum_assignments_old", ["assignment_type"], name: "index_practicum_assignments_old_on_assignment_type", using: :btree
    add_index "practicum_assignments_old", ["name"], name: "index_practicum_assignments_old_on_name", using: :btree
    add_index "practicum_assignments_old", ["person_id"], name: "index_practicum_assignments_old_on_person_id", using: :btree
    add_index "practicum_assignments_old", ["practicum_placement_id"], name: "index_practicum_assignments_old_on_practicum_placement_id", using: :btree
    add_index "practicum_assignments_old", ["practicum_school_id"], name: "index_practicum_assignments_old_on_practicum_school_id", using: :btree
    add_index "practicum_assignments_old", ["supervisor_primary_uid"], name: "index_practicum_assignments_old_on_supervisor_primary_uid", using: :btree
    add_index "practicum_assignments_old", ["supervisor_secondary_uid"], name: "index_practicum_assignments_old_on_supervisor_secondary_uid", using: :btree
    add_index "practicum_assignments_old", ["user_primary_id"], name: "index_practicum_assignments_old_on_user_primary_id", using: :btree
    add_index "practicum_assignments_old", ["user_secondary_id"], name: "index_practicum_assignments_old_on_user_secondary_id", using: :btree

    create_table "practicum_logs", force: :cascade do |t|
      t.integer  "practicum_placement_id", limit: 4
      t.date     "log_date"
      t.string   "type",                   limit: 255
      t.string   "category",               limit: 255
      t.string   "task",                   limit: 255
      t.string   "status",                 limit: 255
      t.integer  "length",                 limit: 4
      t.integer  "user_id",                limit: 4
      t.text     "note",                   limit: 65535
      t.text     "yml",                    limit: 65535
      t.text     "xml",                    limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "practicum_placements", force: :cascade do |t|
      t.integer  "person_id",         limit: 4
      t.integer  "start_term_id",     limit: 4
      t.integer  "end_term_id",       limit: 4
      t.integer  "curriculum_id",     limit: 4
      t.integer  "practicum_site_id", limit: 4
      t.integer  "mentor_person_id",  limit: 4
      t.text     "note",              limit: 65535
      t.string   "type",              limit: 255
      t.string   "category",          limit: 255
      t.string   "status",            limit: 255
      t.string   "dept",              limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "yml",               limit: 65535
      t.text     "xml",               limit: 65535
    end

    add_index "practicum_placements", ["curriculum_id"], name: "index_practicum_placements_on_curriculum_id", using: :btree
    add_index "practicum_placements", ["end_term_id"], name: "index_practicum_placements_on_end_term_id", using: :btree
    add_index "practicum_placements", ["mentor_person_id"], name: "index_practicum_placements_on_mentor_person_id", using: :btree
    add_index "practicum_placements", ["person_id"], name: "index_practicum_placements_on_person_id", using: :btree
    add_index "practicum_placements", ["practicum_site_id"], name: "index_practicum_placements_on_practicum_site_id", using: :btree
    add_index "practicum_placements", ["start_term_id"], name: "index_practicum_placements_on_start_term_id", using: :btree

    create_table "practicum_placements_old", force: :cascade do |t|
      t.integer  "practicum_profile_id", limit: 4
      t.string   "academic_period",      limit: 255
      t.string   "status",               limit: 255
      t.string   "uid",                  limit: 255
      t.string   "sequence",             limit: 255
      t.string   "category",             limit: 255
      t.string   "mentor_type",          limit: 255
      t.text     "note",                 limit: 16777215
      t.string   "dept",                 limit: 255
      t.text     "yml",                  limit: 16777215
      t.text     "xml",                  limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_primary_id",      limit: 4
      t.integer  "user_secondary_id",    limit: 4
      t.integer  "term_id",              limit: 4
    end

    add_index "practicum_placements_old", ["academic_period"], name: "index_practicum_placements_old_on_academic_period", using: :btree
    add_index "practicum_placements_old", ["practicum_profile_id"], name: "index_practicum_placements_old_on_practicum_profile_id", using: :btree
    add_index "practicum_placements_old", ["term_id"], name: "index_practicum_placements_old_on_term_id", using: :btree
    add_index "practicum_placements_old", ["user_primary_id"], name: "index_practicum_placements_old_on_user_primary_id", using: :btree
    add_index "practicum_placements_old", ["user_secondary_id"], name: "index_practicum_placements_old_on_user_secondary_id", using: :btree

    create_table "practicum_profiles_old", force: :cascade do |t|
      t.integer  "person_id",                  limit: 4
      t.integer  "curriculum_id",              limit: 4
      t.string   "bgc",                        limit: 255
      t.date     "bgc_date"
      t.string   "insurance",                  limit: 255
      t.string   "insurance_effective_period", limit: 255
      t.text     "note",                       limit: 16777215
      t.string   "dept",                       limit: 255
      t.text     "yml",                        limit: 16777215
      t.text     "xml",                        limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "coordinator_primary_uid",    limit: 255
      t.string   "coordinator_secondary_uid",  limit: 255
      t.string   "group",                      limit: 255
      t.string   "cohort",                     limit: 255
    end

    add_index "practicum_profiles_old", ["coordinator_primary_uid"], name: "index_practicum_profiles_old_on_coordinator_primary_uid", using: :btree
    add_index "practicum_profiles_old", ["coordinator_secondary_uid"], name: "index_practicum_profiles_old_on_coordinator_secondary_uid", using: :btree
    add_index "practicum_profiles_old", ["curriculum_id"], name: "index_practicum_profiles_old_on_curriculum_id", using: :btree
    add_index "practicum_profiles_old", ["group"], name: "index_practicum_profiles_old_on_group", using: :btree
    add_index "practicum_profiles_old", ["person_id"], name: "index_practicum_profiles_old_on_person_id", using: :btree

    create_table "practicum_schools_old", force: :cascade do |t|
      t.string   "code",        limit: 255
      t.string   "island",      limit: 255
      t.string   "district",    limit: 255
      t.string   "grade_from",  limit: 255
      t.string   "grade_to",    limit: 255
      t.string   "school_type", limit: 255
      t.string   "name",        limit: 255
      t.string   "name_short",  limit: 255
      t.string   "area",        limit: 255
      t.string   "area_group",  limit: 255
      t.string   "url_home",    limit: 255
      t.string   "status",      limit: 255
      t.text     "yml",         limit: 65535
      t.text     "xml",         limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "practicum_schools_old", ["code"], name: "index_practicum_schools_old_on_code", using: :btree

    create_table "practicum_sites", force: :cascade do |t|
      t.string   "code",       limit: 255
      t.string   "name",       limit: 255
      t.string   "name_short", limit: 255
      t.string   "level_from", limit: 255
      t.string   "level_to",   limit: 255
      t.string   "url",        limit: 255
      t.string   "district",   limit: 255
      t.string   "area",       limit: 255
      t.string   "area_group", limit: 255
      t.string   "category",   limit: 255
      t.string   "status",     limit: 255
      t.text     "yml",        limit: 65535
      t.text     "xml",        limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "practicum_sites", ["code"], name: "index_practicum_sites_on_code", using: :btree

    create_table "program_offers", force: :cascade do |t|
      t.integer  "program_id",                limit: 4,                    null: false
      t.string   "distribution",              limit: 255,                  null: false
      t.string   "description",               limit: 255
      t.string   "description_short",         limit: 255
      t.string   "major",                     limit: 255
      t.string   "academic_period",           limit: 255
      t.string   "available_major",           limit: 255
      t.string   "available_academic_period", limit: 255
      t.integer  "sequence",                  limit: 4
      t.boolean  "active",                                  default: true
      t.text     "yml",                       limit: 65535
      t.text     "xml",                       limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "start_term_id",             limit: 4
      t.integer  "end_term_id",               limit: 4
    end

    add_index "program_offers", ["end_term_id"], name: "index_program_offers_on_end_term_id", using: :btree
    add_index "program_offers", ["start_term_id"], name: "index_program_offers_on_start_term_id", using: :btree

    create_table "programs", force: :cascade do |t|
      t.string   "code",                   limit: 255,                  null: false
      t.string   "description",            limit: 255
      t.string   "description_short",      limit: 255
      t.string   "degree",                 limit: 255
      t.string   "major",                  limit: 255
      t.string   "track",                  limit: 255
      t.string   "distribution",           limit: 255
      t.string   "location",               limit: 255
      t.string   "available_major",        limit: 255
      t.string   "available_track",        limit: 255
      t.string   "available_distribution", limit: 255
      t.string   "available_location",     limit: 255
      t.string   "category",               limit: 255
      t.integer  "sequence",               limit: 4
      t.boolean  "active",                               default: true
      t.string   "dept",                   limit: 255
      t.text     "yml",                    limit: 65535
      t.text     "xml",                    limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "programs", ["code"], name: "index_programs_on_code", using: :btree
    add_index "programs", ["degree"], name: "index_programs_on_degree", using: :btree

    create_table "properties", force: :cascade do |t|
      t.string   "name",              limit: 255
      t.string   "code",              limit: 255
      t.string   "description",       limit: 255
      t.string   "description_short", limit: 255
      t.string   "category",          limit: 255
      t.string   "regexp",            limit: 255
      t.integer  "sequence",          limit: 4
      t.boolean  "active",                             default: true
      t.string   "dept",              limit: 255
      t.text     "yml",               limit: 16777215
      t.text     "xml",               limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "sessions", force: :cascade do |t|
      t.string   "session_id", limit: 255,   null: false
      t.text     "data",       limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
    add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

    create_table "terms", force: :cascade do |t|
      t.string   "code",              limit: 255
      t.string   "description",       limit: 255
      t.string   "description_short", limit: 255
      t.date     "start_date"
      t.date     "end_date"
      t.integer  "sequence",          limit: 4
      t.string   "academic_year",     limit: 255
      t.string   "calendar_year",     limit: 255
      t.string   "fiscal_year",       limit: 255
      t.boolean  "regular_term"
      t.boolean  "active",                          default: true
      t.string   "dept",              limit: 255
      t.text     "yml",               limit: 65535
      t.text     "xml",               limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "timestamps", force: :cascade do |t|
      t.integer  "user_id",     limit: 4
      t.string   "remote_ip",   limit: 255
      t.string   "controller",  limit: 255
      t.string   "action",      limit: 255
      t.datetime "created_at"
      t.string   "object_type", limit: 255
      t.integer  "object_id",   limit: 4
      t.string   "path",        limit: 255
      t.string   "agent",       limit: 255
    end

    create_table "transition_actions", force: :cascade do |t|
      t.integer  "transition_point_id", limit: 4
      t.string   "type",                limit: 255
      t.string   "action",              limit: 255
      t.string   "action_specify",      limit: 255
      t.date     "action_date"
      t.string   "note",                limit: 255
      t.integer  "sequence",            limit: 4,     default: 99
      t.integer  "user_id",             limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "yml",                 limit: 65535
      t.text     "xml",                 limit: 65535
    end

    add_index "transition_actions", ["action"], name: "index_transition_actions_on_action", using: :btree
    add_index "transition_actions", ["transition_point_id"], name: "index_transition_actions_on_transition_point_id", using: :btree

    create_table "transition_points", force: :cascade do |t|
      t.integer  "curriculum_id",     limit: 4,                         null: false
      t.integer  "form_id",           limit: 4
      t.string   "academic_period",   limit: 255,   default: "0000000", null: false
      t.string   "type",              limit: 255,   default: "",        null: false
      t.string   "status",            limit: 255
      t.string   "category",          limit: 255
      t.string   "priority",          limit: 255
      t.integer  "user_primary_id",   limit: 4
      t.integer  "user_secondary_id", limit: 4
      t.string   "dept",              limit: 255
      t.boolean  "active",                          default: false
      t.text     "note",              limit: 65535
      t.text     "assessment_note",   limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "yml",               limit: 65535
      t.text     "xml",               limit: 65535
      t.datetime "status_updated_at"
      t.integer  "term_id",           limit: 4
    end

    add_index "transition_points", ["academic_period"], name: "index_transition_points_on_academic_period", using: :btree
    add_index "transition_points", ["curriculum_id"], name: "index_transition_points_on_curriculum_id", using: :btree
    add_index "transition_points", ["dept"], name: "index_transition_points_on_dept", using: :btree
    add_index "transition_points", ["form_id"], name: "index_transition_points_on_form_id", using: :btree
    add_index "transition_points", ["status"], name: "index_transition_points_on_status", using: :btree
    add_index "transition_points", ["status_updated_at"], name: "index_transition_points_on_status_updated_at", using: :btree
    add_index "transition_points", ["term_id"], name: "index_transition_points_on_term_id", using: :btree
    add_index "transition_points", ["type"], name: "index_transition_points_on_type", using: :btree

    create_table "user_assignments", force: :cascade do |t|
      t.integer "user_id",         limit: 4
      t.integer "assignable_id",   limit: 4
      t.string  "assignable_type", limit: 255
    end

    add_index "user_assignments", ["user_id", "assignable_id", "assignable_type"], name: "index_user_assignments_on_user_id_and_assignable_id", unique: true, using: :btree

    create_table "users", force: :cascade do |t|
      t.string   "uid",                 limit: 255
      t.string   "hashed_password",     limit: 255
      t.string   "dept",                limit: 255
      t.integer  "person_id",           limit: 4
      t.string   "category",            limit: 255
      t.string   "position",            limit: 255
      t.string   "department",          limit: 255
      t.integer  "emp_status",          limit: 4,        default: 0
      t.integer  "status",              limit: 4,        default: 0
      t.text     "yml",                 limit: 16777215
      t.text     "xml",                 limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "persistence_token",   limit: 255,                  null: false
      t.string   "single_access_token", limit: 255,                  null: false
      t.string   "perishable_token",    limit: 255,                  null: false
      t.integer  "login_count",         limit: 4,        default: 0, null: false
      t.integer  "login_count",         limit: 4,        default: 0, null: false
      t.integer  "failed_login_count",  limit: 4,        default: 0, null: false
    end

    add_index "users", ["person_id"], name: "index_users_on_person_id", using: :btree
    add_index "users", ["uid"], name: "index_users_on_uid", unique: true, using: :btree
  end

  def down
  end
end
