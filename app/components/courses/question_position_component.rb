module Courses
  class QuestionPositionComponent < QueueInfoComponent
    def initialize(question:)
      @question = question
    end

    def title
      "Position"
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
      return "N/A" unless position.present?
      position == 0 ? "Next" : position + 1
    end

    def position
      question.position_in_course
    end

    private

    attr_reader :question
  end
end