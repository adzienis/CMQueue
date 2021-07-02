class Enrollment < ApplicationRecord
  include Discard::Model

  belongs_to :user, optional: false
  belongs_to :role, optional: false
  has_one :course, through: :role, source: :resource, source_type: 'Course'
  has_one :question_state, -> { order('question_states.id DESC') }
  has_many :question_states
  has_many :questions

  scope :with_course, ->(course) { joins(:role).where("roles.resource_id": course.id) }

  before_validation on: :create do
    self.semester = default_semester if self.semester.nil?
  end

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

  def default_semester
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
