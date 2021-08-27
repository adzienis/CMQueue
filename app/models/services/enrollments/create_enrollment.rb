module Services
  module Enrollments
    class CreateEnrollment < Services::Service
      def initialize(user_id, course_id, code)
        @user_id = user_id
        @course_id = course_id
        @code = code
      end

      def perform
        user = User.all
        user = user.accessible_by(@current_ability)
        user = user.find(@user_id)

        if @code
          ta_course = Course.find_by(ta_code: @code)
          instructor_course = Course.find_by(instructor_code: @code)

          if ta_course
            user.add_role :ta, ta_course
          elsif instructor_course
            user.add_role :instructor, instructor_course
          end
        else
          course = Course.find(@course_id)
          user.add_role :student, course
        end
      end
    end
  end
end