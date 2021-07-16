# frozen_string_literal: true

class QuestionsController < ApplicationController
  load_and_authorize_resource
  def new
    redirect_to queue_course_path(current_user.active_question.course) if current_user.active_question?

    @question = Question.new(enrollment: @enrollment)
    @available_tags = @course.available_tags
  end

  def index
    @course = Course.find(params[:course_id]) if params[:course_id]

    @questions_ransack = @questions.undiscarded.order("questions.created_at": :desc)
    @questions_ransack = @questions_ransack.where(course_id: params[:course_id]) if params[:course_id]

    @questions_ransack = @questions_ransack.joins(:question_states, :user, :tags).ransack(params[:q])

    @pagy, @records = pagy @questions_ransack.result.distinct

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

  def acknowledge
    @question = Question.find(params[:question_id])

    @question.question_state.update(acknowledged_at: DateTime.now)

    redirect_to queue_course_path(@question.course)
  end

  def previous_questions
    @question = Question.find(params[:question_id])

    @questions_ransack = Question.previous_questions(@question).order(created_at: :desc).accessible_by(current_ability).undiscarded
    @questions_ransack = @questions_ransack.where(course_id: params[:course_id]) if params[:course_id]
    @questions_ransack = @questions_ransack.ransack(params[:q])

    @pagy, @records = pagy @questions_ransack.result
  end

  def edit
    @question = Question.find(params[:id])
  end

  def show
    @question = Question.find(params[:id])
  end

  def create
    @question = Question.new(question_params)
    tags = Tag.where(id: params[:question][:tag_ids])

    @question.tags = tags

    @available_tags = @question.course.available_tags

    @question.save

    render turbo_stream: (turbo_stream.replace @question, partial: "form", locals: { question: @question, available_tags: @available_tags}) and return unless @question.errors.count == 0

    redirect_to queue_course_path(@question.course)
  end

  def update_state
    @question = Question.find(params[:question_id])
    @enrollment = current_user.enrollment_with_course(params[:course_id])

    @question.unfreeze(@enrollment.id)
  end

  def download_form
  end

  def update
    @question = Question.find(params[:question_id])
    @available_tags = Tag.undiscarded.unarchived.with_course(@question.course)
    @question.update(question_params)

    tags = Tag.where(id: params[:question][:tag_ids])
    @question.tags = tags

    render turbo_stream: (turbo_stream.replace @question, partial: "form", locals: { question: @question, available_tags: @available_tags}) and return unless @question.errors.count == 0

    redirect_to request.referer
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
    question = Question.find(params[:question_id])
    question.discard

    redirect_to new_course_question_path(question.course, question)
  end

  private

  def question_params
    params.require(:question).permit(:course_id, :description, :tried, :location, :user_id, :title, :enrollment_id)
  end
end
