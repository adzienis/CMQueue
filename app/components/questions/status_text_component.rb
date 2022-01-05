module Questions
  class StatusTextComponent < ViewComponent::Base
    def initialize(question:)
      super
      @question = question
    end

    def msg
      if question.unresolved?
        "Unresolved"
      elsif question.resolving?
        "Resolving"
      elsif question.frozen?
        "Frozen"
      elsif question.kicked?
        "Kicked"
      elsif question.resolved?
        "Resolved"
      end
    end

    def msg_color
      if question.unresolved?
        "text-muted"
      elsif question.resolving?
        "resolving-text"
      elsif question.frozen?
        "frozen-text"
      elsif question.kicked?
        "kicked-text"
      elsif question.resolved?
        "resolved-text"
      end
    end

    private

    attr_reader :question
  end
end