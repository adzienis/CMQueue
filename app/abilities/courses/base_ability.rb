module Courses
  class BaseAbility < ::BaseAbility

    def initialize(user, context)
      super
    end

    private

    def course
      @course ||= Course.find(context[:params][:course_id])
    end

    def enrollment
      @enrollment ||= user.enrollment_in_course(course)
    end

    def role
      @role ||= enrollment.role
    end
  end
end