module Users
  module Enrollments
    class EnrollmentsComponent < ViewComponent::Base
      def initialize(enrollments:)
        super
        @enrollments = enrollments
      end

      private

      attr_reader :enrollments
    end
  end
end