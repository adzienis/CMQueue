class Courses::AnswerController < ApplicationController
  before_action :authorize

  def current_ability
    @current_ability ||= ::CourseAbility.new(current_user, {
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def authorize
    authorize! :answer, @course
  end

  def show
    return redirect_to queue_course_path(@course) unless current_user.handling_question?(course: @course)

    question_state = current_user.question_state
    @question = question_state&.question
  end
end
