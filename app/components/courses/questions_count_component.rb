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
      course.active_questions.latest_by_state("unresolved", "frozen").count
    end

    private

    attr_reader :course
  end
end