class Forms::Questions::QuestionCreatorComponent < ViewComponent::Base
  def initialize(course:, current_user:, question_form: nil, question: nil)
    @course        = course
    @question_form = question_form
    @current_user  = current_user
    @question      = question
  end

  def question
    @question || question_form&.question
  end

  def question_form
    return @question_form if @question_form.present?
    return Forms::Question.new(question: @question) if @question.present?
    Forms::Question.new(question: Question.new)
  end

  def creator_classes
    classes = ""
    classes = "#{classes} frozen-card" if question.frozen?
    classes = "#{classes} disabled" if question.course.present? && !question.course&.open? && question.new_record?
    classes
  end

  private

  attr_reader :course, :current_user
end
