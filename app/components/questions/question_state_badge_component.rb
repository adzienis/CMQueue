class Questions::QuestionStateBadgeComponent < ViewComponent::Base
  def initialize(question_state:)
    @question_state = question_state
  end

  def state
    question_state.state
  end

  def class_param
    bg_class = if state == "unresolved"
                 "bg-unresolved"
               elsif state == "resolving"
                 "bg-resolving"
               elsif state == "frozen"
                 "bg-frozen"
               elsif state == "kicked"
                 "bg-kicked"
               elsif state == "resolved"
                 "bg-resolved"
               end

    "badge #{bg_class}"
  end

  private

  attr_reader :question_state
end
