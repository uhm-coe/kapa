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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170807213532) do

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

  create_table "files", force: :cascade do |t|
    t.integer  "person_id",         limit: 4
    t.integer  "attachable_id",     limit: 4
    t.string   "attachable_type",   limit: 255
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
    t.integer  "user_id",           limit: 4
  end

  add_index "files", ["person_id"], name: "index_files_on_person_id", using: :btree

  create_table "form_details", force: :cascade do |t|
    t.integer  "form_id",       limit: 4,     null: false
    t.integer  "form_field_id", limit: 4
    t.text     "value",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "yml",           limit: 65535
    t.text     "xml",           limit: 65535
  end

  add_index "form_details", ["form_field_id"], name: "index_assessment_scores_on_scorable_and_criterion_id", unique: true, using: :btree

  create_table "form_fields", force: :cascade do |t|
    t.string   "label",            limit: 255
    t.text     "label_desc",       limit: 65535
    t.text     "label_html",       limit: 65535
    t.string   "category",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "form_template_id", limit: 4
    t.text     "yml",              limit: 65535
    t.text     "xml",              limit: 65535
    t.string   "type",             limit: 255,   default: "default", null: false
    t.string   "type_option",      limit: 255
    t.boolean  "required"
    t.boolean  "active",                         default: true
  end

  create_table "form_template_fields", force: :cascade do |t|
    t.string   "field_label",      limit: 255
    t.text     "field_desc",       limit: 65535
    t.text     "field_html",       limit: 65535
    t.string   "field_category",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "form_template_id", limit: 4
    t.text     "yml",              limit: 65535
    t.text     "xml",              limit: 65535
    t.string   "type",             limit: 255,   default: "default", null: false
    t.string   "type_option",      limit: 255
    t.boolean  "required"
    t.boolean  "hide"
  end

  create_table "form_templates", force: :cascade do |t|
    t.string   "title",            limit: 255
    t.string   "reference_url",    limit: 255
    t.string   "dept",             limit: 255
    t.text     "yml",              limit: 65535
    t.text     "xml",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "program",          limit: 255
    t.string   "course",           limit: 255
    t.string   "transition_point", limit: 255
    t.string   "start_term",       limit: 255
    t.string   "end_term",         limit: 255
    t.string   "type",             limit: 255
    t.string   "template_path",    limit: 255
    t.text     "note",             limit: 65535
    t.boolean  "attachment"
    t.boolean  "active",                         default: true
  end

  add_index "form_templates", ["course"], name: "index_form_template_on_course", using: :btree
  add_index "form_templates", ["end_term"], name: "index_form_template_on_end_term_id", using: :btree
  add_index "form_templates", ["start_term"], name: "index_form_template_on_start_term_id", using: :btree

  create_table "forms", force: :cascade do |t|
    t.string   "type",             limit: 255
    t.integer  "person_id",        limit: 4
    t.string   "term",             limit: 255
    t.integer  "file_id",          limit: 4
    t.integer  "attachable_id",    limit: 4
    t.string   "attachable_type",  limit: 255
    t.datetime "submitted_at"
    t.string   "submit_ip",        limit: 255
    t.string   "lock",             limit: 255,      default: "N"
    t.text     "note",             limit: 16777215
    t.string   "public",           limit: 255,      default: "Y"
    t.integer  "version",          limit: 4
    t.string   "dept",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "yml",              limit: 16777215
    t.text     "xml",              limit: 16777215
    t.integer  "form_template_id", limit: 4
    t.string   "submitted_by",     limit: 255
  end

  add_index "forms", ["person_id"], name: "index_forms_on_person_id", using: :btree
  add_index "forms", ["term"], name: "index_forms_on_term", using: :btree
  add_index "forms", ["type"], name: "index_forms_on_type", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.integer  "attachable_id",   limit: 4
    t.string   "attachable_type", limit: 255
    t.string   "type",            limit: 255
    t.string   "title",           limit: 255
    t.text     "body",            limit: 65535
    t.string   "sequence",        limit: 255
    t.boolean  "read",                          default: false
    t.boolean  "email_sent",                    default: false
    t.text     "yml",             limit: 65535
    t.text     "xml",             limit: 65535
    t.datetime "read_at"
    t.datetime "email_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "persons", force: :cascade do |t|
    t.string   "id_number",       limit: 255
    t.string   "ets_id",          limit: 255
    t.string   "uid",             limit: 255
    t.string   "type",            limit: 255
    t.string   "last_name",       limit: 255
    t.string   "first_name",      limit: 255
    t.string   "middle_initial",  limit: 255
    t.string   "other_name",      limit: 255
    t.string   "title",           limit: 255
    t.date     "birth_date"
    t.string   "ethnicity",       limit: 255
    t.string   "gender",          limit: 255
    t.string   "ssn",             limit: 255
    t.text     "ssn_crypted",     limit: 16777215
    t.string   "ssn_agreement",   limit: 255
    t.string   "email",           limit: 255
    t.string   "email_alt",       limit: 255
    t.string   "cur_phone",       limit: 255
    t.string   "per_phone",       limit: 255
    t.string   "business_phone",  limit: 255
    t.string   "mobile_phone",    limit: 255
    t.string   "cur_street",      limit: 255
    t.string   "cur_city",        limit: 255
    t.string   "cur_state",       limit: 255
    t.string   "cur_postal_code", limit: 255
    t.string   "per_street",      limit: 255
    t.string   "per_city",        limit: 255
    t.string   "per_state",       limit: 255
    t.string   "per_postal_code", limit: 255
    t.string   "fax",             limit: 255
    t.string   "source",          limit: 255
    t.string   "status",          limit: 255,      default: "N"
    t.text     "note",            limit: 16777215
    t.string   "dept",            limit: 255
    t.text     "yml",             limit: 16777215
    t.text     "xml",             limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "persons", ["email"], name: "index_persons_on_email", using: :btree
  add_index "persons", ["id_number"], name: "index_persons_on_id_number", unique: true, using: :btree
  add_index "persons", ["status"], name: "index_persons_on_status", using: :btree

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

  add_index "properties", ["name", "code"], name: "index_properties_on_name_and_code", unique: true, using: :btree

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

  create_table "text_templates", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.text     "body",       limit: 65535
    t.string   "type",       limit: 255
    t.string   "sequence",   limit: 255
    t.string   "category",   limit: 255
    t.boolean  "active",                   default: true
    t.string   "dept",       limit: 255
    t.text     "yml",        limit: 65535
    t.text     "xml",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "texts", force: :cascade do |t|
    t.integer  "person_id",        limit: 4
    t.integer  "attachable_id",    limit: 4
    t.string   "attachable_type",  limit: 255
    t.integer  "text_template_id", limit: 4
    t.string   "title",            limit: 255
    t.text     "body",             limit: 65535
    t.string   "sequence",         limit: 255
    t.string   "category",         limit: 255
    t.string   "status",           limit: 255
    t.string   "dept",             limit: 255
    t.text     "note",             limit: 65535
    t.text     "yml",              limit: 65535
    t.text     "xml",              limit: 65535
    t.datetime "submitted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "texts", ["person_id"], name: "index_texts_on_person_id", using: :btree
  add_index "texts", ["text_template_id"], name: "index_texts_on_text_template_id", using: :btree

  create_table "timestamps", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "path",       limit: 255
    t.string   "remote_ip",  limit: 255
    t.string   "agent",      limit: 255
    t.datetime "created_at"
  end

  add_index "timestamps", ["user_id"], name: "index_timestamps_on_user_id", using: :btree

  create_table "user_assignments", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.integer  "assignable_id",   limit: 4
    t.string   "assignable_type", limit: 255
    t.string   "task",            limit: 255
    t.datetime "due_at"
    t.text     "yml",             limit: 16777215
    t.text     "xml",             limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_assignments", ["user_id", "assignable_id", "assignable_type"], name: "index_user_assignments_on_user_id_and_assignable_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "uid",                 limit: 255
    t.string   "hashed_password",     limit: 255
    t.string   "dept",                limit: 255
    t.string   "primary_dept",        limit: 255
    t.integer  "person_id",           limit: 4
    t.string   "category",            limit: 255
    t.string   "position",            limit: 255
    t.integer  "status",              limit: 4,        default: 0
    t.text     "yml",                 limit: 16777215
    t.text     "xml",                 limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "persistence_token",   limit: 255,                  null: false
    t.string   "single_access_token", limit: 255,                  null: false
    t.string   "perishable_token",    limit: 255,                  null: false
    t.integer  "login_count",         limit: 4,        default: 0, null: false
    t.integer  "failed_login_count",  limit: 4,        default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip",    limit: 255
    t.string   "last_login_ip",       limit: 255
    t.string   "password_salt",       limit: 255
  end

  add_index "users", ["person_id"], name: "index_users_on_person_id", using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", unique: true, using: :btree

end
