class QuestionStatesController < ApplicationController
  load_and_authorize_resource

  def index
    @question_states = @question_states.joins(:question).where("questions.course_id": params[:course_id]) if params[:course_id]
    @course = Course.find(params[:course_id]) if params[:course_id]

    @question_states_ransack = @question_states.ransack(params[:q])

    @pagy, @records = pagy @question_states_ransack.result
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