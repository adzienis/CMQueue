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

ActiveRecord::Schema.define(version: 2021_04_07_224826) do

  create_table "courses", force: :cascade do |t|
    t.string "name"
    t.string "course_code"
    t.string "student_code"
    t.string "ta_code"
    t.string "instructor_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "enrollments", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "course_id"
    t.integer "user_id"
    t.integer "role"
    t.index ["course_id", "user_id"], name: "index_enrollments_on_course_id_and_user_id", unique: true
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "question_queues", force: :cascade do |t|
    t.integer "course_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id"], name: "index_question_queues_on_course_id"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "question_queue_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["question_queue_id"], name: "index_questions_on_question_queue_id"
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

  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "users"
end
