class Forms::Questions::FormComponent < ViewComponent::Base
  def initialize(question_form:, course:, current_user:)
    @question_form = question_form
    @course = course
    @current_user = current_user
  end

  def question
    @question ||= question_form.question
  end

  def course
    @course ||= question.course
  end

  def tag_groups?
    return false unless course.present?
    course.tag_groups.filter{|v| v.tags.present? }.present?
  end

  private

  attr_reader :question_form, :course, :current_user
end
