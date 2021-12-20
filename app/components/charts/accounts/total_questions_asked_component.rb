module Charts
  module Accounts
    class TotalQuestionsAskedComponent < ViewComponent::Base
      def initialize(user:)
        super
        @user = user
      end

      def enrollments_with_questions
        @enrollments ||= user.enrollments.joins(:questions, role: :course)
          .select("enrollments.id, roles.resource_id course_id, COUNT(*) count, courses.name course_name")
          .group("enrollments.id, roles.resource_id, courses.name")
          .having("COUNT(*) > 0")
      end

      private

      attr_reader :user
    end
  end
end
