module Courses
  class QuestionsCountComponent < QueueInfoComponent
    def initialize(course:)
      @course = course
    end

    def title
      "Unresolved Questions"
    end

    def footer
    end

    def info
      nil
    end

    def value_style
      ""
    end

    def value
      course.active_questions.count
    end

    private

    attr_reader :course
  end
end