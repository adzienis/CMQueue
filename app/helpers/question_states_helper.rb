# frozen_string_literal: true

module QuestionStatesHelper
  class QuestionStatesPresenter
    attr_accessor :question

    def initialize(question)
      @question = question
    end

    def creator_classes
      (@question.frozen? ? "frozen-card" : "").to_s
    end

    def creator_styles
      if @question.user&.active_question?
        ""
      else
        (@question.course&.open ? "" : "pointer-events: none; opacity: .6").to_s
      end
    end
  end
end
