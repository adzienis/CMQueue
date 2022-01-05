module Admin
  module Courses
    module Search
      class ResultRowComponent < ViewComponent::Base
        def initialize(course:)
          super
          @course = course
        end

        def open_class
          course.open? ? "bg-success" : "bg-danger"
        end

        def open_msg
          course.open? ? "Open" : "False"
        end

        private

        attr_reader :course
      end
    end
  end
end
