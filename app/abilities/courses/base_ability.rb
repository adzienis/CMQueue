module Courses
  class BaseAbility < ::BaseAbility

    private

    def course
      @course ||= context[:course]
    end

    def enrollment
      @enrollment ||= user.enrollment_in_course(course)
    end

    def role
      @role ||= enrollment.role
    end
  end
end