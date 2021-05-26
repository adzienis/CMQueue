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

ActiveRecord::Schema.define(version: 2021_05_23_033554) do

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
    t.boolean "open"
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
    t.bigint "course_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id", "user_id"], name: "index_enrollments_on_course_id_and_user_id", unique: true
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "question_state_id"
    t.text "description", default: ""
    t.boolean "seen", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["question_state_id"], name: "index_messages_on_question_state_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
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
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "state", null: false
    t.index ["question_id"], name: "index_question_states_on_question_id"
    t.index ["user_id"], name: "index_question_states_on_user_id"
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "course_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "title"
    t.text "tried"
    t.text "description"
    t.text "notes"
    t.text "location"
    t.index ["course_id"], name: "index_questions_on_course_id"
    t.index ["user_id"], name: "index_questions_on_user_id"
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
    t.bigint "question_state_id"
    t.string "provider"
    t.string "uid"
    t.index ["question_state_id"], name: "index_users_on_question_state_id"
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

  add_foreign_key "messages", "question_states"
  add_foreign_key "messages", "users"
  add_foreign_key "question_states", "questions"
  add_foreign_key "question_states", "users"
  add_foreign_key "questions", "courses"
  add_foreign_key "questions", "users"
  add_foreign_key "questions_tags", "questions"
  add_foreign_key "questions_tags", "tags"
end
