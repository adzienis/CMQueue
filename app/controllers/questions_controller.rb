# frozen_string_literal: true

class QuestionsController < ApplicationController
  load_and_authorize_resource

  def index
    @course = Course.find(params[:course_id]) if params[:course_id]

    @questions_ransack = @questions.undiscarded.order(updated_at: :desc)
    @questions_ransack = @questions_ransack.where(course_id: params[:course_id]) if params[:course_id]
    @questions_ransack = @questions_ransack.ransack(params[:q])

    @pagy, @records = pagy @questions_ransack.result

    respond_to do |format|
      format.html
      # to download file with form submit
      format.js { render inline: "window.open('#{URI::HTTP.build(path: "#{request.path}.csv", query: request.query_parameters.to_query, format: :csv)}', '_blank')"}
      format.csv { send_data helpers.to_csv(params[:question].to_unsafe_h, @questions_ransack.result, Question), filename: "test.csv" }
    end
  end

  def count
    @course = Course.find(params[:course_id]) if params[:course_id]

    @questions = Question.joins(:user, :question_state, :tags)
    @questions = @questions.where(course_id: params[:course_id]) if params[:course_id]
    @questions = @questions.where(user_id: params[:user_id]) if params[:user_id]
    @questions = @questions.questions_by_state(JSON.parse(params[:state])) if params[:state]

    respond_to do |format|
      format.html
      format.json do
        render json: @questions.count
      end
    end
  end

  def previous_questions
    @course = Course.find(params[:course_id]) if params[:course_id]
    @question = Question.find(params[:id])

    @questions_ransack = Question.previous_questions(@question).order(:created_at).accessible_by(current_ability).undiscarded
    @questions_ransack = @questions_ransack.where(course_id: params[:course_id]) if params[:course_id]
    @questions_ransack = @questions_ransack.ransack(params[:q])

    @pagy, @records = pagy @questions_ransack.result
  end

  def edit
    @question = Question.find(params[:id])
    @course = Course.find(params[:course_id]) if params[:course_id]
  end

  def show
    @course = Course.find(params[:course_id]) if params[:course_id]
    @question = Question.find(params[:id])
  end

  def create; end

  def download_form
  end

  def update
    @question = Question.find(params[:id])
    @question.update(question_params)
    @question.tags = (Tag.find(params[:question][:tags])) if params.dig(:question, :tags)

    respond_to do |format|
      format.html { redirect_to course_questions_path(@question.course) }
      format.json { render json: @question }
    end
  end

  def paginated_previous_questions
    @question = Question.find(params[:id])
    @paginated_past_questions = Question
                                  .left_joins(:question_state)
                                  .where("question_states.state = #{QuestionState.states['resolved']}")
                                  .where('questions.created_at < ?', @question.created_at)
                                  .where(user_id: @question.user_id)
                                  .where(course_id: @question.course_id)
                                  .order('question_states.created_at DESC')
                                  .limit(5)
    respond_to do |format|
      format.html
      format.json { render json: @paginated_past_questions, include: :question_state }
    end
  end

  def destroy
    Question.find(params[:id]).discard
  end

  private

  def question_params
    params.require(:question).permit(:course_id, :description, :tried, :location, :user_id, :title)
  end
end
