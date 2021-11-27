module Courses
  module Feed
    class QuestionCardComponent < ViewComponent::Base
      def initialize(question:)
        @question = question
      end

      def state
        question.question_state.state
      end

      def status_badge_msg
        return "Frozen" if question.frozen?
        ""
      end

      def status_badge_class
        return "badge bg-frozen" if question.frozen?
        ""
      end

      def status_badge?
        question.frozen?
      end

      def footer?
        question.frozen?
      end

      def status_class
        return "frozen-text" if question.frozen?
        "text-muted"
      end

      def status_msg
        return "Frozen since #{question.created_at.to_formatted_s(:american_short)}" if question.frozen?
        "Waiting since #{question.created_at.to_formatted_s(:american_short)}"
      end

      private

      attr_reader :question
    end
  end
end
