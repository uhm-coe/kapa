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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180501103350) do

  create_table "calendar_events", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "person_id"
    t.string "title"
    t.string "dow"
    t.boolean "repeat", default: false
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "uuid"
    t.text "note"
    t.text "yml"
    t.text "xml"
    t.index ["person_id"], name: "index_calendar_events_on_person_id"
  end

  create_table "datasets", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "description"
    t.string "type"
    t.string "category"
    t.string "datasource"
    t.text "query"
    t.string "ldap_base"
    t.string "ldap_filter"
    t.text "ldap_attr"
    t.integer "record_count"
    t.datetime "loaded_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "yml"
    t.text "xml"
  end

  create_table "files", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "person_id"
    t.integer "attachable_id"
    t.string "attachable_type"
    t.string "name"
    t.string "type"
    t.string "status"
    t.string "uploaded_by"
    t.string "dept"
    t.string "public", default: "N"
    t.text "note"
    t.string "data_file_name"
    t.string "data_content_type"
    t.integer "data_file_size"
    t.datetime "data_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "yml"
    t.text "xml"
    t.integer "user_id"
    t.index ["person_id"], name: "index_files_on_person_id"
  end

  create_table "form_fields", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "form_template_field_id", null: false
    t.text "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "yml"
    t.text "xml"
    t.integer "form_id", null: false
    t.index ["form_id", "form_template_field_id"], name: "index_form_fields_on_form_id_and_form_template_field_id", unique: true
  end

  create_table "form_template_fields", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "label"
    t.text "label_desc"
    t.text "label_html"
    t.string "category"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "form_template_id"
    t.text "yml"
    t.text "xml"
    t.string "type", default: "default", null: false
    t.string "type_option"
    t.boolean "active", default: true
    t.boolean "required"
    t.integer "sequence", default: 0
  end

  create_table "form_templates", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "start_term"
    t.string "end_term"
    t.string "title"
    t.string "course"
    t.string "reference_url"
    t.string "dept"
    t.text "yml"
    t.text "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "program"
    t.string "assessment_type"
    t.string "transition_point"
    t.string "type"
    t.string "template_path"
    t.text "note"
    t.boolean "attachment"
    t.index ["course"], name: "index_form_templates_on_course"
    t.index ["end_term"], name: "index_form_templates_on_end_term"
    t.index ["start_term"], name: "index_form_templates_on_start_term"
  end

  create_table "forms", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "type"
    t.integer "person_id"
    t.string "term"
    t.integer "file_id"
    t.integer "attachable_id"
    t.string "attachable_type"
    t.datetime "submitted_at"
    t.string "submit_ip"
    t.string "lock", default: "N"
    t.text "note", limit: 16777215
    t.string "public", default: "Y"
    t.integer "version"
    t.string "dept"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "yml", limit: 16777215
    t.text "xml", limit: 16777215
    t.integer "form_template_id"
    t.string "submitted_by"
    t.string "status"
    t.index ["person_id"], name: "index_forms_on_person_id"
    t.index ["term"], name: "index_forms_on_term"
    t.index ["type"], name: "index_forms_on_type"
  end

  create_table "notifications", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.integer "attachable_id"
    t.string "attachable_type"
    t.string "type"
    t.string "title"
    t.text "body"
    t.string "sequence"
    t.boolean "read", default: false
    t.boolean "email_sent", default: false
    t.text "yml"
    t.text "xml"
    t.datetime "read_at"
    t.datetime "email_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "persons", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "id_number"
    t.string "ets_id"
    t.string "uid"
    t.string "type"
    t.string "last_name"
    t.string "first_name"
    t.string "middle_initial"
    t.string "other_name"
    t.string "title"
    t.date "birth_date"
    t.string "ethnicity"
    t.string "gender"
    t.string "ssn"
    t.text "ssn_crypted", limit: 16777215
    t.string "ssn_agreement"
    t.string "email"
    t.string "email_alt"
    t.string "cur_phone"
    t.string "per_phone"
    t.string "business_phone"
    t.string "mobile_phone"
    t.string "cur_street"
    t.string "cur_city"
    t.string "cur_state"
    t.string "cur_postal_code"
    t.string "per_street"
    t.string "per_city"
    t.string "per_state"
    t.string "per_postal_code"
    t.string "fax"
    t.string "source"
    t.string "status", default: "N"
    t.text "note", limit: 16777215
    t.string "dept"
    t.text "yml", limit: 16777215
    t.text "xml", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "suffix"
    t.index ["email"], name: "index_persons_on_email"
    t.index ["id_number"], name: "index_persons_on_id_number", unique: true
    t.index ["status"], name: "index_persons_on_status"
  end

  create_table "programs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "code", null: false
    t.string "description"
    t.string "description_short"
    t.string "degree"
    t.string "major"
    t.string "track"
    t.string "distribution"
    t.string "location"
    t.string "available_major"
    t.string "available_track"
    t.string "available_distribution"
    t.string "available_location"
    t.string "category"
    t.integer "sequence"
    t.boolean "active", default: true
    t.string "dept"
    t.text "yml"
    t.text "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_programs_on_code"
    t.index ["degree"], name: "index_programs_on_degree"
  end

  create_table "properties", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "code"
    t.string "description"
    t.string "description_short"
    t.string "category"
    t.string "regexp"
    t.integer "sequence"
    t.boolean "active", default: true
    t.string "dept"
    t.text "yml", limit: 16777215
    t.text "xml", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "code"], name: "index_properties_on_name_and_code", unique: true
  end

  create_table "sessions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "terms", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "code"
    t.string "description"
    t.string "description_short"
    t.date "start_date"
    t.date "end_date"
    t.integer "sequence"
    t.string "academic_year"
    t.string "calendar_year"
    t.string "fiscal_year"
    t.boolean "regular_term"
    t.boolean "active", default: true
    t.string "dept"
    t.text "yml"
    t.text "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "text_templates", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title"
    t.text "body"
    t.string "type"
    t.string "sequence"
    t.string "category"
    t.boolean "active", default: true
    t.string "dept"
    t.text "yml"
    t.text "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "texts", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "person_id"
    t.integer "attachable_id"
    t.string "attachable_type"
    t.integer "text_template_id"
    t.string "title"
    t.text "body"
    t.string "sequence"
    t.string "category"
    t.string "status"
    t.string "dept"
    t.text "note"
    t.text "yml"
    t.text "xml"
    t.datetime "submitted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["person_id"], name: "index_texts_on_person_id"
    t.index ["text_template_id"], name: "index_texts_on_text_template_id"
  end

  create_table "timestamps", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.string "path"
    t.string "remote_ip"
    t.string "agent"
    t.datetime "created_at"
    t.index ["user_id"], name: "index_timestamps_on_user_id"
  end

  create_table "user_assignments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.integer "assignable_id"
    t.string "assignable_type"
    t.string "task"
    t.datetime "due_at"
    t.text "yml", limit: 16777215
    t.text "xml", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "assignable_id", "assignable_type"], name: "index_user_assignments_on_user_id_and_assignable_id"
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "uid"
    t.string "hashed_password"
    t.string "dept"
    t.string "primary_dept"
    t.integer "person_id"
    t.string "category"
    t.string "position"
    t.integer "status", default: 0
    t.text "yml", limit: 16777215
    t.text "xml", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "persistence_token", null: false
    t.string "single_access_token", null: false
    t.string "perishable_token", null: false
    t.integer "login_count", default: 0, null: false
    t.integer "failed_login_count", default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string "current_login_ip"
    t.string "last_login_ip"
    t.string "password_salt"
    t.index ["person_id"], name: "index_users_on_person_id"
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

end
