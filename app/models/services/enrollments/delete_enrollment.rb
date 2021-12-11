module Services
  module Enrollments
    class DeleteEnrollment < Services::Service
      def initialize(enrollment_id)
        super()

        @enrollment_id = enrollment_id
      end

      def perform
        enrollment = Enrollment.find(@enrollment_id)

        @current_ability.authorize! :delete, enrollment
        enrollment.discard
      end
    end
  end
end
