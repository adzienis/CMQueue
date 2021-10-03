class Courses::HandleQuestionController < ApplicationController

  respond_to :json

  def create
    question = Question.find(params[:question_id])

    ret = question.transition_to_state(params[:state], params[:enrollment_id])

    respond_with question
  end
end
