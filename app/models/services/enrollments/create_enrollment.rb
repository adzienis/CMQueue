module Services
  module Enrollments
    class CreateEnrollment < Services::Service
      def initialize(user_id, course_id, code)
        super()
        @user_id = user_id
        @course_id = course_id
        @code = code
      end

      def perform
        user = User.all
        user = user.accessible_by(@current_ability)
        user = user.find(@user_id)

        @current_ability.authorize! :enroll_user, user

        role = nil

        if @code
          ta_course = Course.find_by(ta_code: @code)
          instructor_course = Course.find_by(instructor_code: @code)

          if ta_course
            role = user.add_role :ta, ta_course
          elsif instructor_course
            role = user.add_role :instructor, instructor_course
          end
        else
          course = Course.find(@course_id)
          role = user.add_role :student, course
        end

        user.enrollments.undiscarded.with_role(role.id).first
      end
    end
  end
end