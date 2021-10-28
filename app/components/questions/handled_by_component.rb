class Questions::HandledByComponent < ViewComponent::Base
  def initialize(question:)
    @question = question
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

    "badge rounded-pill #{bg_class}"
  end

  def render?
    @question.question_state.user != @question.user &&
    @question.question_state.state != "unresolved"
  end

  def user_name
    @question.question_state.user.given_name
  end

  private

  attr_reader :question
end
