class CreateKapaSchema < ActiveRecord::Migration[5.2]
  def change

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
      t.integer "file_id", limit: 4
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

    create_table "timestamps", force: :cascade do |t|
      t.integer "user_id", limit: 4
      t.string "path", limit: 255
      t.string "remote_ip", limit: 255
      t.string "agent", limit: 255
      t.datetime "created_at"
    end

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
  end
end
