class Questions::HandledByComponent < ViewComponent::Base

  delegate :question_state, to: :question

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

  def label_msg
    if state == "resolved"
      "Resolved By"
    else
      "Currently Handled By"
    end
  end

  def state
    question_state.state
  end

  def render?
    question_state.user != question.user &&
    question_state.state != "unresolved"
  end

  def user_name
    question_state.user.given_name
  end

  private

  attr_reader :question
end
