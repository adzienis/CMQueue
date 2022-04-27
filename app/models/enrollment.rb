# == Schema Information
#
# Table name: enrollments
#
#  id           :bigint           not null, primary key
#  user_id      :bigint
#  role_id      :bigint
#  semester     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#  section      :string
#
require "pagy/extras/searchkick"

class Enrollment < ApplicationRecord
  include Discard::Model
  include Exportable
  include Exportable
  include Turbo::Broadcastable
  extend Pagy::Searchkick

  has_paper_trail(limit: nil)
  searchkick index_prefix: -> {}
  kredis_hash "course_state"
  scope :search_import, -> { includes(:role) }

  def search_data
    {
      id: id,
      user_id: user_id,
      full_name: user.full_name,
      role_name: role.name,
      semester: semester,
      discarded_at: discarded_at,
      created_at: created_at,
      course_id: course&.id,
      sections: courses_sections.map(&:name)
    }
  end

  belongs_to :user
  belongs_to :role
  has_one :course, through: :role
  has_one :question_state, -> { order("question_states.id DESC") }
  has_and_belongs_to_many :courses_sections, class_name: "Courses::Section", association_foreign_key: :courses_section_id
  has_many :question_states, dependent: :destroy
  has_many :questions, inverse_of: :enrollment, dependent: :destroy

  validate :unique_enrollment_in_course_per_semester, on: :create
  validate :semester_valid

  def self.semesters
    ["F21", "S22"]
  end

  def semester_valid
    errors.add(:semester, "invalid") unless Enrollment.semesters.include?(semester)
  end

  def unique_enrollment_in_course_per_semester
    return if user_id.nil? || role_id.nil? || semester.nil?

    found = Enrollment
              .active
              .joins(:role)
              .where("roles.resource_id": role.resource_id, "roles.resource_type": "Course", user_id: user_id, semester: semester)

    if found.exists?
      SpecialLogger.info("here: #{found.first.to_yaml}")
      errors.add(:base, :already_exists)
    end
  end

  before_validation do
    self.semester = Enrollment.default_semester if semester.nil?
  end

  def active?
    undiscarded? && archived_at.nil?
  end

  def archive!
    transaction do
      self.archived_at = DateTime.current
      save!
    end
    reload
  end

  scope :active, -> { undiscarded.where(archived_at: nil) }
  scope :with_role, ->(role_id) { joins(:role).where("roles.id": role_id) }
  scope :with_role_names, ->(*role_names) do
    joins(:role).where("roles.name": role_names, "roles.resource_type": "Course")
  end
  scope :with_user, ->(user_id) { joins(:user).where("users.id": user_id) }
  scope :with_courses, ->(courses) { joins(:role).merge(Role.with_resources(courses)) }

  scope :with_course_roles, ->(*roles) { joins(:role).where("roles.name": roles, "roles.resource_type": "Course") }

  after_commit do
    reindex(refresh: true)
  end

  def student?
    role.name == "student" && role.resource == course
  end

  def instructor?
    role.name == "instructor" && role.resource == course
  end

  def ta?
    role.name == "ta" && role.resource == course
  end

  def staff?
    Role.staff_role_names.include?(role.name) && role.resource == course
  end

  def privileged?
    Role.privileged_role_names.include?(role.name) && role.resource == course
  end

  def student_role
    roles.find_by(name: "student")
  end

  def ta_role
    roles.find_by(name: "ta")
  end

  def instructor_role
    roles.find_by(name: "instructor")
  end

  def lead_ta_role
    roles.find_by(name: "lead_ta")
  end

  def selected_tags=(tags)
    course_state[:selected_tags] = JSON.dump(tags)
  end

  def selected_tags
    selected_tags = course_state[:selected_tags]
    return JSON.parse(selected_tags) if selected_tags.present? && JSON.parse(selected_tags).present?
    course_state[:selected_tags] = []
  end

  private

  def self.default_semester_full
    time = Time.now

    if time.month < 5
      "Spring #{time.strftime("%Y")}"
    elsif time.month == 5
      if time.day <= 19
        "Spring #{time.strftime("%Y")}"
      else
        "Summer #{time.strftime("%Y")}"
      end
    elsif time.month < 8
      "Summer #{time.strftime("%Y")}"
    elsif time.month == 8
      if time.day <= 19
        "Summer #{time.strftime("%Y")}"
      else
        "Fall #{time.strftime("%Y")}"
      end
    else
      "Fall #{time.strftime("%Y")}"
    end
  end

  def self.default_semester
    time = Time.now

    if time.month < 5
      "S#{time.strftime("%y")}"
    elsif time.month == 5
      if time.day <= 19
        "S#{time.strftime("%y")}"
      else
        "Su#{time.strftime("%y")}"
      end
    elsif time.month < 8
      "Su#{time.strftime("%y")}"
    elsif time.month == 8
      if time.day <= 19
        "Su#{time.strftime("%y")}"
      else
        "F#{time.strftime("%y")}"
      end
    elsif time.month < 12
      "F#{time.strftime("%y")}"
    elsif time.day <= 15
      "F#{time.strftime("%y")}"
    else
      "S#{(time + 1.year).strftime("%y")}"
    end
  end
end
