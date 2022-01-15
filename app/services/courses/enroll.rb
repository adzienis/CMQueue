module Courses
  class Enroll
    def initialize(role_name:, user:, course:)
      @role_name = role_name
      @user = user
      @course = course
    end

    def call
      user.enrollments.create!(role: role)
    end

    private

    def role
      course.roles.find_by(name: role_name)
    end

    attr_reader :role_name, :user, :course
  end
end