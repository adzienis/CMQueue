class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course


  after_create do
    ActionCable.server.broadcast "react-students", {
      invalidate: ['user', 'enrollments']
    }
  end

  after_destroy do
    user.roles.find_by(resource_id: course_id).destroy

    ActionCable.server.broadcast "react-students", {
      invalidate: ['user', 'enrollments']
    }
  end
end
