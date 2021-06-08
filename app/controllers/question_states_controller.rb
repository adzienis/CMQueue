class QuestionStatesController < ApplicationController
  load_and_authorize_resource

  def index
    @question_states = QuestionState.all
    @question_states = @question_states.where(search_params) unless search_params.empty?
    @question_states = @question_states.left_outer_joins(:question).where("questions.")

    render json: @question_states
  end

  def edit
  end

  def create
    @question_state = QuestionState.create!(create_params)

    respond_to do |format|
      format.html
      format.json { render json: @question_state }
    end
  end

  def show
    @course = Course.find(params[:course_id]) if params[:course_id]
    @question_state = QuestionState.find(params[:id])
  end
  private

  def create_params
    params.require(:question_state).permit(:user_id, :course_id, :state, :question_id)
  end

  def search_params
    params.permit(:question_id, :user_id, :course_id)
  end
end
