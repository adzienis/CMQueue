class Forms::Question::QuestionCreatorComponent < ViewComponent::Base
  def initialize(course:, question_form:, current_user:)
    @course = course
    @question_form = question_form
    @current_user = current_user
  end

  def question
    question_form.question
  end

  def creator_classes
    classes = ""
    classes = "#{classes} frozen-card" if question.frozen?
    classes = "#{classes} disabled" if question.course.present? && !question.course&.open? && question.new_record?
    classes
  end

  private

  attr_reader :course, :question_form, :current_user
end
