class Enrollment < ApplicationRecord
  include Discard::Model
  include RansackableConcern

  enum semester: { Su21: "Su21", F21: "F21" }

  validates :user_id, :role_id, :semester, presence: true

  belongs_to :user, optional: false
  belongs_to :role, optional: false
  has_one :course, through: :role, source: :resource, source_type: 'Course'
  has_one :question_state, -> { order('question_states.id DESC') }
  has_many :question_states, dependent: :destroy
  has_many :questions, dependent: :destroy

  validate :unique_enrollment_in_course_per_semester, on: :create

  def unique_enrollment_in_course_per_semester
    return if user_id.nil? || role_id.nil? || semester.nil?

    found = Enrollment
              .undiscarded
              .joins(:role)
              .where("roles.resource_id": role.resource_id, "roles.resource_type": "Course", user_id: user_id, semester: semester)

    unless found.empty?
      errors.add(:enrollment, "already exists in course.")
    end

  end

  before_validation on: :create do
    self.semester = Enrollment.default_semester if self.semester.nil?
  end

  scope :with_course, ->(course) { joins(:role).where("roles.resource_id": course.id) }

  scope :with_course_roles, ->(*roles){ joins(:role).where("roles.name": roles, "roles.resource_type": "Course") }

  after_create do
    ActionCable.server.broadcast 'react-students', {
      invalidate: ['users', user.id, 'enrollments']
    }
  end

  after_destroy do
    ActionCable.server.broadcast 'react-students', {
      invalidate: ['users', user.id, 'enrollments']
    }
  end

  after_discard do
    ActionCable.server.broadcast 'react-students', {
      invalidate: ['users', user.id, 'enrollments']
    }
  end

  def self.most_recent_enrollment_by_course(course_id)
    course = Course.find_by(id: course_id)
    return nil unless course
    undiscarded.with_course(course).order(created_at: :desc).first
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
    elsif time.month < 9
      "Summer #{time.strftime("%Y")}"
    elsif time.month == 9
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
    elsif time.month < 9
      "Su#{time.strftime("%y")}"
    elsif time.month == 9
      if time.day <= 19
        "Su#{time.strftime("%y")}"
      else
        "F#{time.strftime("%y")}"
      end
    else
      "F#{time.strftime("%y")}"
    end
  end
end
