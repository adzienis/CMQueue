module Courses
  class OpenButtonComponent < ViewComponent::Base
    def initialize(course:)
      @course = course
    end

    def open?
      course.open
    end

    def msg
      open? ? "Close" : "Open"
    end

    def loading_msg
      open? ? "Closing" : "Opening"
    end

    def button_class
      open? ? "btn-success" : "btn-danger"
    end

    private

    attr_reader :course
  end
end
