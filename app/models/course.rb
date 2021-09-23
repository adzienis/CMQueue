# frozen_string_literal: true

require './lib/postgres/views/course'
require './lib/postgres/views/question'
require './lib/postgres/views/tag'
require './lib/postgres/views/enrollment'
require './lib/postgres/views/user'
require './lib/postgres/views/question_state'
require './lib/postgres/views'

class Course < ApplicationRecord
  resourcify

  # to prevent accidentally exposing sensitive columns
  default_scope { select(Course.column_names - ["instructor_code", "ta_code", "student_code"]) }

  validates :name, presence: true, uniqueness: true
  validates :ta_code, presence: true, uniqueness: true, on: :create
  validates :student_code, presence: true, uniqueness: true, on: :create
  validates :instructor_code, presence: true, uniqueness: true, on: :create

  # Not required for now
  # validates :course_code, presence: true, uniqueness: true

  has_one :certificate
  has_many :tag_groups
  has_many :enrollments, through: :roles, dependent: :destroy
  has_many :settings, as: :resource
  has_many :users, through: :enrollments
  has_many :questions, dependent: :destroy
  has_many :unresolved_questions, -> { undiscarded.questions_by_state("unresolved") }, class_name: "Question"

  has_many :tas, -> { joins(:enrollments)
                        .merge(Enrollment
                                 .undiscarded
                                 .with_course(id)
                                 .with_course_roles(["ta"]))
  }, class_name: "Question"
  has_many :instructors, -> { joins(:role).undiscarded.with_course_roles(["ta"]) }, class_name: "Enrollment"
  has_many :students, -> { joins(:enrollments) }, class_name: "Question"

  has_many :active_questions, -> { undiscarded
                                     .questions_by_state("unresolved", "frozen", "resolving")
                                     .or(undiscarded.by_state("kicked").unacknowledged) }, class_name: "Question"
  has_many :tags, dependent: :destroy
  #has_many :announcements

  has_many :access_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :delete_all

  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :delete_all

  has_many :applications, class_name: "Doorkeeper::Application", as: :owner

  before_validation on: :create do
    self.ta_code = SecureRandom.urlsafe_base64(6) unless ta_code.present?
    self.student_code = SecureRandom.urlsafe_base64(6) unless student_code.present?
    self.instructor_code = SecureRandom.urlsafe_base64(6) unless instructor_code.present?
  end

  scope :with_user, ->(user_id) {
    joins(:enrollments).merge(Enrollment.undiscarded.with_user(user_id))
  }


  def self.find_by_code?(code)
    self.find_by_code(code).present?
  end

  def self.find_by_code(code)
    ta_course = Course.find_by(ta_code: code)
    instructor_course = Course.find_by(instructor_code: code)


    return ta_course, :ta if ta_course
    return instructor_course, :instructor if instructor_course

    return nil
  end

  def available_tags
    tags.undiscarded.unarchived.distinct
  end

  def public_columns
    select(Course.column_names - ["instructor_code", "ta_code"])
  end

  after_update do
    broadcast_action_later_to self,
                              action: :refresh,
                              target: "question-creator-container",
                              template: nil

    QueueChannel.broadcast_to self, {
      invalidate: ['courses', id, 'open']
    }
  end

  after_create_commit do

    Postgres::Views.create_views_schema(id)
    Postgres::Views::Course.create(id)
    Postgres::Views::Question.create(id)
    Postgres::Views::Tag.create(id)
    Postgres::Views::Enrollment.create(id)
    Postgres::Views::QuestionState.create(id)
    Postgres::Views::User.create(id)

    settings.create([{
                       value: {
                         searchable: {
                           label: "Searchable",
                           value: false,
                           description: "Allow students to search for this course.",
                           type: "boolean",
                           category: "General"
                         }
                       }
                     }, {
                       value: {
                         searchable_enrollment: {
                           label: "Searchable Enrollment",
                           value: false,
                           description: "Allow enrollment by searching for this course.",
                           type: "boolean",
                           category: "Enrollment"
                         }
                       }
                     }, {
                       value: {
                         allow_enrollment: {
                           label: "Allow Enrollment",
                           value: false,
                           description: "Allow students to enroll in the course.",
                           type: "boolean",
                           category: "Enrollment"
                         }
                       }
                     }])
  end

  after_destroy_commit do
    Postgres::Views::Course.destroy(id)
    Postgres::Views::Question.destroy(id)
    Postgres::Views::Tag.destroy(id)
    Postgres::Views::Enrollment.destroy(id)

    Postgres::Views.destroy_user(id)
  end
end
