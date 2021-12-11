module Courses
  class QuestionPositionComponent < QueueInfoComponent
    def initialize(question:, position: nil)
      @question = question
      @position = position
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
      return "N/A" if question.destroyed?
      return "N/A" unless wrapped_position.present?
      (wrapped_position + 1).ordinalize
    end

    def wrapped_position
      return position if position.present?

      question.position_in_course
    end

    private

    attr_reader :question, :position
  end
end
