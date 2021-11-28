# == Schema Information
#
# Table name: courses
#
#  id              :bigint           not null, primary key
#  name            :string
#  course_code     :string
#  student_code    :string
#  ta_code         :string
#  instructor_code :string
#  open            :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require './lib/postgres/views/course'
require './lib/postgres/views/question'
require './lib/postgres/views/tag'
require './lib/postgres/views/enrollment'
require './lib/postgres/views/user'
require './lib/postgres/views/question_state'
require './lib/postgres/views'

class Course < ApplicationRecord
  include Turbo::Broadcastable
  include HasEnrollables
  searchkick

  # to prevent accidentally exposing sensitive columns
  default_scope { select(Course.column_names - ["instructor_code", "ta_code", "student_code"]) }

  validates :name, presence: true, uniqueness: true
  validates :ta_code, presence: true, uniqueness: true, on: :create
  validates :student_code, presence: true, uniqueness: true, on: :create
  validates :instructor_code, presence: true, uniqueness: true, on: :create

  # Not required for now
  # validates :course_code, presence: true, uniqueness: true

  has_one :certificate
  has_many :tag_groups, dependent: :destroy
  has_many :settings, as: :resource, dependent: :destroy
  has_many :questions, through: :enrollments
  has_many :analytics_dashboards, :class_name => 'Analytics::Dashboard'
  has_many :unresolved_questions, -> { undiscarded.by_state("unresolved") }, class_name: "Question"

  has_many :active_questions, -> { where("questions.id in (#{Question.undiscarded
                                                                     .by_state("unresolved", "frozen", "resolving")
                                                                     .select("questions.id")
                                                                     .to_sql}) or " +
                                           "questions.id in (#{Question.undiscarded
                                                                       .by_state("kicked")
                                                                       .unacknowledged
                                                                       .select("questions.id")
                                                                       .to_sql})") }, through: :enrollments, class_name: "Question", source: :questions

  has_many :questions_on_queue, -> { by_state("unresolved", "frozen").undiscarded },
           through: :enrollments,
           source: :questions,
           class_name: "Question"
  has_many :all_questions_on_queue, -> { by_state("unresolved", "frozen", "resolving").undiscarded },
           through: :enrollments,
           source: :questions,
           class_name: "Question"
  has_many :tags, dependent: :destroy
  #has_many :announcements

  has_many :access_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :destroy

  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :destroy

  has_many :applications, class_name: "Doorkeeper::Application", as: :owner
  has_many :courses_sections, :class_name => 'Courses::Section'

  has_one :ta_role, -> { where(name: "ta") },
          class_name: "Role",
          dependent: :destroy,
          inverse_of: :course
  has_one :instructor, -> { where(name: "instructor") },
          class_name: "Role",
          dependent: :destroy,
          inverse_of: :course
  has_one :lead_ta, -> { where(name: "lead_ta") },
          class_name: "Role",
          dependent: :destroy,
          inverse_of: :course
  has_one :student, -> { where(name: "student") },
          class_name: "Role",
          dependent: :destroy,
          inverse_of: :course

  before_validation on: :create do
    self.ta_code = SecureRandom.urlsafe_base64(6) unless ta_code.present?
    self.student_code = SecureRandom.urlsafe_base64(6) unless student_code.present?
    self.instructor_code = SecureRandom.urlsafe_base64(6) unless instructor_code.present?
  end

  scope :with_user, ->(user_id) {
    joins(:enrollments).merge(Enrollment.undiscarded.with_user(user_id))
  }

  scope :with_setting_value, ->(key, value) { joins(:settings).merge(Setting.with_key_value(key, value)) }

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

  def setting(key)
    settings.option_value_of_key(key)
  end

  # Course Roles Finders
  ######################################################3

  def self.find_staff_roles(user = nil)
    Role.joins(enrollments: :user).where("users.id": user)
        .where("roles.resource_type": "Course", name: [:ta, :lead_ta, :instructor])
        .merge(Enrollment.undiscarded)
  end

  def self.find_unprivileged_roles(user = nil)
    Course.find_roles([:student], user)
  end

  def self.find_privileged_staff_roles(user = nil)
    Course.find_roles([:lead_ta, :instructor], user)
  end

  def answerable_questions?(tag_names: nil)
    if tag_names.present?
      active_questions
        .includes(:question_state)
        .joins(:tags)
        .where("tags.name": tag_names)
        .group("questions.id")
        .having("count(*) = #{tag_names.count}")
        .filter { |q| q.unresolved? }.any?
    else
      active_questions
        .includes(:question_state)
        .joins(:tags)
        .filter { |q| q.unresolved? }.any?
    end
  end

  def student_role
    roles.find_by("roles.name": "student")
  end

  def instructor_role
    roles.find_by("roles.name": "instructor")
  end

  def ta_role
    roles.find_by("roles.name": "ta")
  end

  def lead_ta_role
    roles.find_by("roles.name": "lead_ta")
  end

  def available_tags
    tags.undiscarded.unarchived.distinct
  end

  def public_columns
    select(Course.column_names - ["instructor_code", "ta_code"])
  end

  after_commit do
    RenderComponentJob.perform_later("Courses::QueueOpenStatusComponent",
                                     self,
                                     opts: { target: "queue-open-status" },
                                     component_args: { course: self })

    if open_previously_was == false && open == true
      CourseChannel.broadcast_to self, {
        type: "event",
        event: "course:open",
        payload: {
          course_id: id
        }
      }

    elsif open_previously_was == true && open == false
      CourseChannel.broadcast_to self, {
        type: "event",
        event: "course:close",
        payload: {
          course_id: id
        }
      }
    end

    if open_changed?
      RenderComponentJob.perform_later("Courses::OpenButtonComponent",
                                       self,
                                       opts: { target: "open-button" },
                                       component_args: { course: self })
    end
  end

  after_create_commit do

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

    roles.create([{ name: "instructor" }, { name: "ta" }, { name: "student" }, { name: "lead_ta" }])

  end

  after_destroy_commit do
    Postgres::Views::Course.destroy(id)
    Postgres::Views::Question.destroy(id)
    Postgres::Views::Tag.destroy(id)
    Postgres::Views::Enrollment.destroy(id)

    Postgres::Views.destroy_user(id)
  end
end
