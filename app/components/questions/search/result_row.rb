module Questions
  module Search
    class ResultRow < ViewComponent::Base
      def initialize(question:)
        super
        @question = question
      end

      private

      attr_reader :question
    end
  end
end
