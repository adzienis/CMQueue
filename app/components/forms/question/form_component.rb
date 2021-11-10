class Forms::Question::FormComponent < ViewComponent::Base
  def initialize(question_form:, course:, current_user:)
    @question_form = question_form
    @course = course
    @current_user = current_user
  end

  def question
    question_form.question
  end

  private

  attr_reader :question_form, :course, :current_user
end