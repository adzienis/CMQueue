class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course
  belongs_to :role, optional: true

  scope :with_course, ->(course) { where(course_id: course.id)}

  after_create do
    ActionCable.server.broadcast "react-students", {
      invalidate: ['users', user.id, 'enrollments']
    }
  end

  after_destroy do
    user.roles.find_by(resource_id: course_id)&.destroy

    ActionCable.server.broadcast "react-students", {
      invalidate: ['users', user.id, 'enrollments']
    }
  end
end
