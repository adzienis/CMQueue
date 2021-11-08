module Courses
  class QueueOpenStatusComponent < QueueOpenStatusComponent
    def initialize(course:)
      super
      @course = course
    end
  end
end