# frozen_string_literal: true

class QuestionStatesController < ApplicationController
  load_and_authorize_resource

  respond_to :html, :json

  def index
    @course = Course.find(params[:course_id]) if params[:course_id]

    @question_states = @question_states.where(question_id: params[:question_id]) if params[:question_id]

    @question_states = @question_states.order("question_states.created_at": :desc).joins(:question).where("questions.course_id": params[:course_id]) if params[:course_id]

    @question_states_ransack = @question_states.ransack(params[:q])

    @pagy, @records = pagy @question_states_ransack.result.distinct

    respond_with @question_states
  end

  def edit; end

  def create
    @question_state = QuestionState.create!(create_params)
  end

  def show
    @course = Course.find(params[:course_id]) if params[:course_id]
    @question_state = QuestionState.find(params[:id])
  end

  private

  def create_params
    params.require(:question_state).permit(:user_id, :course_id, :state, :question_id, :description, :enrollment_id)
  end

  def search_params
    params.permit(:question_id, :course_id, :enrollment_id)
  end
end
