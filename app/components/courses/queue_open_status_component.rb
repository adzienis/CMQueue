module Courses
  class QueueOpenStatusComponent < QueueInfoComponent
    def initialize(course:)
      @course = course
    end

    def title
      "Queue Status"
    end

    def footer
    end

    def info
      nil
    end

    def value_style
      course.open ? "color: green" : "color: red"
    end

    def value
      course.open ? "Open" : "Closed"
    end

    private

    attr_reader :course
  end
end
