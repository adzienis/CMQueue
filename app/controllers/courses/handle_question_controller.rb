class Courses::HandleQuestionController < ApplicationController
  respond_to :json

  def current_ability
    @current_ability ||= ::CourseAbility.new(current_user, {
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def create
    authorize! :answer, @course

    question = Question.find(params[:question_id])

    ret = question.transition_to_state(params[:state], params[:enrollment_id])

    respond_with question
  end
end
