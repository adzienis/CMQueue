module Courses
  module Feed
    class FeedComponent < ViewComponent::Base
      def initialize(search:, course:, questions:, pagy:)
        super
        @search = search
        @course = course
        @questions = questions
        @pagy = pagy
      end

      def tags
        search.aggs["tags"]["buckets"].map { |k| k["key"] }
      end

      def available_tags
        course.available_tags
      end

      private

      attr_reader :course, :questions, :pagy, :search
    end
  end
end
