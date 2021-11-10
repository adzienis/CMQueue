class Forms::Question::QuestionCreatorComponent < ViewComponent::Base
  def initialize(course:, question_form:, current_user:)
    @course = course
    @question_form = question_form
    @current_user = current_user
  end

  def question
    @question_form.question
  end

  def creator_classes
    "#{ question.frozen? ? "frozen-card" : ""}"
  end

  def creator_styles
    if question.user&.active_question?
      ""
    else
      "#{question.course&.open ? "" : "pointer-events: none; opacity: .6"}"
    end
  end

  private

  attr_reader :course, :question_form, :current_user
end