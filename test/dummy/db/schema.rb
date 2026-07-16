# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2023_09_29_054220) do
  create_table "contents", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "html"
    t.json "json"
    t.string "page", null: false
    t.string "region", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "yml"
    t.index ["page", "region"], name: "index_contents_on_page_and_region", unique: true
    t.index ["page"], name: "index_contents_on_page"
  end

  create_table "files", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "active", default: true
    t.integer "attachable_id"
    t.string "attachable_type"
    t.datetime "created_at", precision: nil
    t.string "data_content_type"
    t.string "data_file_name"
    t.integer "data_file_size"
    t.datetime "data_updated_at", precision: nil
    t.string "dept"
    t.json "json"
    t.string "name"
    t.text "note"
    t.integer "person_id"
    t.string "public", default: "N"
    t.string "status"
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.string "uploaded_by"
    t.integer "user_id"
    t.text "yml"
    t.index ["person_id"], name: "index_files_on_person_id"
  end

  create_table "form_template_fields", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", precision: nil
    t.integer "form_template_id"
    t.text "hint"
    t.json "json"
    t.text "label"
    t.string "name"
    t.boolean "required"
    t.integer "sequence", default: 0
    t.text "tip"
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.text "yml"
  end

  create_table "form_templates", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "attachment"
    t.datetime "created_at", precision: nil
    t.string "dept"
    t.json "json"
    t.text "note"
    t.string "template_path"
    t.string "title"
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.text "yml"
  end

  create_table "forms", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "active", default: true
    t.integer "attachable_id"
    t.string "attachable_type"
    t.datetime "created_at", precision: nil
    t.string "dept"
    t.integer "file_id"
    t.integer "form_template_id"
    t.json "json"
    t.string "lock", default: "N"
    t.text "note", size: :medium
    t.integer "person_id"
    t.string "public", default: "Y"
    t.string "status"
    t.string "submit_ip"
    t.datetime "submitted_at", precision: nil
    t.string "submitted_by"
    t.integer "term_id"
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.integer "version"
    t.text "yml", size: :medium
    t.index ["person_id"], name: "index_forms_on_person_id"
    t.index ["term_id"], name: "index_forms_on_term_id"
    t.index ["type"], name: "index_forms_on_type"
  end

  create_table "messages", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.text "bcc"
    t.text "body"
    t.text "cc"
    t.string "content_type", default: "text/html"
    t.datetime "created_at"
    t.boolean "email_sent", default: false
    t.text "from"
    t.json "json"
    t.integer "messageable_id"
    t.string "messageable_type"
    t.boolean "read", default: false
    t.datetime "read_at"
    t.text "reply_to"
    t.datetime "sent_at"
    t.string "subject"
    t.text "to"
    t.string "type"
    t.datetime "updated_at"
    t.text "yml"
    t.index ["messageable_type", "messageable_id"], name: "index_messages_on_messageable_type_and_messageable_id"
  end

  create_table "notifications", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "attachable_id"
    t.string "attachable_type"
    t.text "body"
    t.datetime "created_at", precision: nil
    t.boolean "email_sent", default: false
    t.datetime "email_sent_at", precision: nil
    t.json "json"
    t.boolean "read", default: false
    t.datetime "read_at", precision: nil
    t.string "sequence"
    t.string "title"
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.text "yml"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "persons", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "birth_date"
    t.string "business_phone"
    t.datetime "created_at", precision: nil
    t.string "cur_city"
    t.string "cur_phone"
    t.string "cur_postal_code"
    t.string "cur_state"
    t.string "cur_street"
    t.string "dept"
    t.string "email"
    t.string "email_alt"
    t.string "ethnicity"
    t.string "ets_id"
    t.string "fax"
    t.string "first_name"
    t.string "gender"
    t.string "id_number"
    t.json "json"
    t.string "last_name"
    t.string "middle_initial"
    t.string "mobile_phone"
    t.text "note", size: :medium
    t.string "other_name"
    t.string "per_city"
    t.string "per_phone"
    t.string "per_postal_code"
    t.string "per_state"
    t.string "per_street"
    t.string "source"
    t.string "ssn"
    t.string "ssn_agreement"
    t.text "ssn_crypted", size: :medium
    t.string "status", default: "N"
    t.string "suffix"
    t.string "title"
    t.string "type"
    t.string "uid"
    t.datetime "updated_at", precision: nil
    t.text "yml", size: :medium
    t.index ["email"], name: "index_persons_on_email"
    t.index ["id_number"], name: "index_persons_on_id_number", unique: true
    t.index ["status"], name: "index_persons_on_status"
  end

  create_table "programs", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "available_distribution"
    t.string "available_location"
    t.string "available_major"
    t.string "available_track"
    t.string "category"
    t.string "code", null: false
    t.datetime "created_at", precision: nil
    t.string "degree"
    t.string "dept"
    t.string "description"
    t.string "description_short"
    t.string "distribution"
    t.json "json"
    t.string "location"
    t.string "major"
    t.integer "sequence"
    t.string "track"
    t.datetime "updated_at", precision: nil
    t.text "yml"
    t.index ["code"], name: "index_programs_on_code"
    t.index ["degree"], name: "index_programs_on_degree"
  end

  create_table "properties", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "category"
    t.string "code"
    t.datetime "created_at", precision: nil
    t.string "dept"
    t.string "description"
    t.string "description_short"
    t.json "json"
    t.string "name"
    t.string "regexp"
    t.integer "sequence"
    t.datetime "updated_at", precision: nil
    t.text "yml", size: :medium
    t.index ["name", "code"], name: "index_properties_on_name_and_code", unique: true
  end

  create_table "sessions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "data"
    t.json "json"
    t.string "session_id", null: false
    t.datetime "updated_at", precision: nil
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "terms", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "academic_year"
    t.boolean "active", default: true
    t.string "calendar_year"
    t.string "code"
    t.datetime "created_at", precision: nil
    t.string "dept"
    t.string "description"
    t.string "description_short"
    t.date "end_date"
    t.string "fiscal_year"
    t.json "json"
    t.boolean "regular_term"
    t.integer "sequence"
    t.date "start_date"
    t.datetime "updated_at", precision: nil
    t.text "yml"
  end

  create_table "text_templates", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "active", default: true
    t.text "body"
    t.string "category"
    t.datetime "created_at", precision: nil
    t.string "dept"
    t.json "json"
    t.string "sequence"
    t.string "template_path"
    t.string "title"
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.text "yml"
  end

  create_table "texts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "active", default: true
    t.integer "attachable_id"
    t.string "attachable_type"
    t.text "body"
    t.string "category"
    t.datetime "created_at", precision: nil
    t.string "dept"
    t.json "json"
    t.text "note"
    t.integer "person_id"
    t.string "sequence"
    t.string "status"
    t.datetime "submitted_at", precision: nil
    t.integer "text_template_id"
    t.string "title"
    t.datetime "updated_at", precision: nil
    t.text "yml"
    t.index ["person_id"], name: "index_texts_on_person_id"
    t.index ["text_template_id"], name: "index_texts_on_text_template_id"
  end

  create_table "timestamps", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "agent"
    t.datetime "created_at", precision: nil
    t.json "json"
    t.string "method"
    t.string "path"
    t.string "remote_ip"
    t.integer "user_id"
    t.index ["user_id"], name: "index_timestamps_on_user_id"
  end

  create_table "user_assignments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "assignable_id"
    t.string "assignable_type"
    t.datetime "created_at", precision: nil
    t.datetime "due_at", precision: nil
    t.json "json"
    t.string "task"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.text "yml", size: :medium
    t.index ["user_id", "assignable_id", "assignable_type"], name: "index_user_assignments_on_user_id_and_assignable_id"
  end

  create_table "users", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", precision: nil
    t.datetime "current_login_at", precision: nil
    t.string "current_login_ip"
    t.string "dept"
    t.integer "failed_login_count", default: 0, null: false
    t.string "hashed_password"
    t.json "json"
    t.datetime "last_login_at", precision: nil
    t.string "last_login_ip"
    t.datetime "last_request_at", precision: nil
    t.integer "login_count", default: 0, null: false
    t.string "password_salt"
    t.string "perishable_token", null: false
    t.string "persistence_token", null: false
    t.integer "person_id"
    t.string "position"
    t.string "primary_dept"
    t.string "role"
    t.string "single_access_token", null: false
    t.integer "status", default: 0
    t.string "uid"
    t.datetime "updated_at", precision: nil
    t.text "yml", size: :medium
    t.index ["person_id"], name: "index_users_on_person_id"
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end
end
