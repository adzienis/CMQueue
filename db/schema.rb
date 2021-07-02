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

ActiveRecord::Schema.define(version: 2021_07_01_224457) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "announcements", force: :cascade do |t|
    t.string "title", default: ""
    t.text "description", default: ""
    t.boolean "visible", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "courses", force: :cascade do |t|
    t.string "name"
    t.string "course_code"
    t.string "student_code"
    t.string "ta_code"
    t.string "instructor_code"
    t.boolean "open", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "courses_questions", id: false, force: :cascade do |t|
    t.bigint "course_id"
    t.bigint "question_id"
    t.index ["course_id"], name: "index_courses_questions_on_course_id"
    t.index ["question_id"], name: "index_courses_questions_on_question_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.string "semester"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_enrollments_on_discarded_at"
    t.index ["role_id"], name: "index_enrollments_on_role_id"
    t.index ["semester"], name: "index_enrollments_on_semester"
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "question_state_id"
    t.text "description", default: ""
    t.boolean "seen", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "enrollment_id", null: false
    t.index ["enrollment_id"], name: "index_messages_on_enrollment_id"
    t.index ["question_state_id"], name: "index_messages_on_question_state_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.string "type", null: false
    t.jsonb "params"
    t.datetime "read_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes", default: "", null: false
    t.string "resource_owner_type", null: false
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id", "resource_owner_type"], name: "polymorphic_owner_oauth_access_grants"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.string "resource_owner_type"
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id", "resource_owner_type"], name: "polymorphic_owner_oauth_access_tokens"
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri"
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "owner_id"
    t.string "owner_type"
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "question_queues", force: :cascade do |t|
    t.bigint "course_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "archived", default: true
    t.index ["course_id"], name: "index_question_queues_on_course_id"
  end

  create_table "question_states", force: :cascade do |t|
    t.bigint "question_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description"
    t.integer "state", null: false
    t.bigint "enrollment_id", null: false
    t.index ["enrollment_id"], name: "index_question_states_on_enrollment_id"
    t.index ["question_id"], name: "index_question_states_on_question_id"
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "course_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "title"
    t.text "tried"
    t.text "description"
    t.text "notes"
    t.text "location"
    t.datetime "discarded_at"
    t.bigint "enrollment_id", null: false
    t.index ["course_id"], name: "index_questions_on_course_id"
    t.index ["discarded_at"], name: "index_questions_on_discarded_at"
    t.index ["enrollment_id"], name: "index_questions_on_enrollment_id"
  end

  create_table "questions_tags", id: false, force: :cascade do |t|
    t.bigint "tag_id"
    t.bigint "question_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["question_id"], name: "index_questions_tags_on_question_id"
    t.index ["tag_id"], name: "index_questions_tags_on_tag_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "settings", force: :cascade do |t|
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "key", null: false
    t.string "value", null: false
    t.integer "setting_type", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["resource_type", "resource_id"], name: "index_settings_on_resource"
  end

  create_table "tags", force: :cascade do |t|
    t.bigint "course_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "archived", default: true
    t.text "name", default: ""
    t.text "description", default: ""
    t.index ["course_id"], name: "index_tags_on_course_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "given_name"
    t.text "family_name"
    t.text "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "uid"
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "courses_questions", "courses"
  add_foreign_key "courses_questions", "questions"
  add_foreign_key "enrollments", "roles"
  add_foreign_key "enrollments", "users"
  add_foreign_key "messages", "enrollments"
  add_foreign_key "messages", "question_states"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "question_states", "enrollments"
  add_foreign_key "question_states", "questions"
  add_foreign_key "questions", "courses"
  add_foreign_key "questions", "enrollments"
  add_foreign_key "questions_tags", "questions"
  add_foreign_key "questions_tags", "tags"
  add_foreign_key "tags", "courses"
end
