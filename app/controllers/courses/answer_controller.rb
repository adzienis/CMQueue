class Courses::AnswerController < ApplicationController
  before_action :authorize

  def authorize
    authorize! :answer, @course
  end

  def show
    redirect_to queue_course_path(@course) and return unless current_user.handling_question?(course: @course)

    question_state = current_user.question_state
    @question = question_state&.question
  end
end
