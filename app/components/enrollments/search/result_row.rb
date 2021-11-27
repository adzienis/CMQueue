module Enrollments
  module Search
    class ResultRow < ViewComponent::Base
      def initialize(enrollment:)
        super
        @enrollment = enrollment
      end

      private

      attr_reader :enrollment
    end
  end
end
