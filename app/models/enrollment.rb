class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course

  after_create do
    ActionCable.server.broadcast "react-students", {
      invalidate: ['user', 'enrollments']
    }
  end

  after_destroy do
    ActionCable.server.broadcast "react-students", {
      invalidate: ['user', 'enrollments']
    }
  end
end
