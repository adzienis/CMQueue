module Users
  module Enrollments
    class EnrollmentComponent < ViewComponent::Base
      def initialize(enrollment:)
        super
        @enrollment = enrollment
      end

      def course
        enrollment.course
      end

      def role
        enrollment.role
      end

      def link
        return queue_course_path(course) if enrollment.staff?
        new_course_forms_question_path(course) if enrollment.student?
      end

      def footer_class
        if role.name == "ta"
          "bg-ta"
        elsif role.name == "instructor"
          "bg-instructor"
        elsif role.name == "student"
          "bg-student"
        end
      end

      private

      attr_reader :enrollment
    end
  end
end
