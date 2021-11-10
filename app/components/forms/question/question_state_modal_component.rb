class Forms::Question::QuestionStateModalComponent < ViewComponent::Base
  def initialize(course:, question:)
    super
    @course = course
    @question = question
  end

  private

  attr_reader :course, :question
end