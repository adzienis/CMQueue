module Users
  module Enrollments
    module EnrollBySearch
      class SearchComponent < ViewComponent::Base
        def initialize(enrollment:)
          super
          @enrollment = enrollment
        end

        private

        attr_reader :enrollment
      end
    end
  end
end
