class Questions::HandleController < ApplicationController

  respond_to :json, :html

  before_action :set_resource, only: :create
  before_action :authorize

  def authorize
    authorize! :create_handle, @question
  end

  def set_resource
    @question = Question.find(params[:question_id])
  end

  def create
    @question = Question.find(params[:question_id])
    @question.transition_to_state(params[:state], params[:enrollment_id], description: params[:description])

    redirect_to queue_course_path(@question.course)
  end
end
