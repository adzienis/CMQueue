class Questions::HandleController < ApplicationController

  respond_to :json

  before_action :set_resource, only: :create

  def set_resource
    @questions = Question.accessible_by(current_ability)
    @question = @questions.find(params[:question_id])
  end


  def create
    ret = @question.transition_to_state(params[:state], params[:enrollment_id])

    respond_with @question
  end
end
