class Questions::CountController < ApplicationController
  respond_to :json

  def current_ability
    @current_ability ||= ::QuestionAbility.new(current_user, {
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def show
    authorize! :count, Question

    @questions = Question.undiscarded.order(:created_at)
    @questions = @questions.with_courses(params[:course_id]) if params[:course_id]
    @questions = @questions.with_users(params[:user_id]) if params[:user_id]
    @questions = @questions.by_state(JSON.parse(params[:state])) if params[:state]

    @questions = @questions.count

    respond_with @questions
  end
end
