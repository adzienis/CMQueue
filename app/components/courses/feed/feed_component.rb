module Courses
  module Feed
    class FeedComponent < ViewComponent::Base
      def initialize(course:, questions:, current_user:, pagy:)
        super

        @course = course
        @questions = questions
        @current_user = current_user
        @pagy = pagy
      end

      def available_tags
        course.available_tags
      end

      private

      attr_reader :course, :questions, :current_user, :pagy

    end
  end
end