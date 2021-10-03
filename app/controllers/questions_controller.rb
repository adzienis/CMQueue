# frozen_string_literal: true

class QuestionsController < ApplicationController
  load_and_authorize_resource id_param: :question_id

  include ResourceInitializable
  include ResourceAuthorizable
  include CourseFilterable
  include UserFilterable

  respond_to :html, :json, :csv

  def new
    redirect_to queue_course_path(current_user.active_question.course) if current_user.active_question?

    @question = Question.new(enrollment: @enrollment)
    @available_tags = @course.available_tags
  end

  def position
    @questions = @questions.undiscarded
    @questions = @questions.questions_by_state(JSON.parse(params[:state])) if params[:state]

    respond_with @questions.pluck(:id).index(params[:question_id].to_i)
  end
  def index
    @questions = @questions.undiscarded.order(:created_at) #.order("max(question_states.state) desc").group("questions.id")
    @questions = @questions.latest_by_state(JSON.parse(params[:state])) if params[:state]

    @questions_ransack = @questions.ransack(params[:q])

    @pagy, @records = pagy @questions_ransack.result

    @questions = @questions.count if params[:agg] == "count"

    respond_with @questions
  end

  def acknowledge
    @question.question_state.update(acknowledged_at: DateTime.now)

    redirect_to queue_course_path(@question.course)
  end

  def previous_questions
    @question = @questions.find(params[:question_id])

    @questions = @questions.previous_questions(@question).order(created_at: :desc).accessible_by(current_ability).undiscarded
    @questions = @questions.where(course_id: params[:course_id]) if params[:course_id]
    @questions_ransack = @questions.ransack(params[:q])

    @pagy, @records = pagy @questions_ransack.result

    respond_with @questions
  end

  def edit
    @question = @questions.find(params[:question_id])
  end

  def show
    @question = @questions.find(params[:question_id])

    respond_with @question do |format|
      format.json { render json: @question.as_json(include: [:user, :tags, :question_state])}
    end
  end

  def create
    @question = Question.new(question_params)

    @question.save

    render turbo_stream: (turbo_stream.replace @question, partial: "form", locals: { question: @question, available_tags: @available_tags}) and return unless @question.errors.count == 0

    redirect_to queue_course_path(@question.course)
  end

  def update_state
    @question = @questions.find(params[:question_id])
    @enrollment = current_user.enrollment_in_course(params[:course_id])

    @question.unfreeze(@enrollment.id)
  end

  def download_form
  end

  def update
    @question = @questions.find(params[:question_id])
    @available_tags = Tag.undiscarded.unarchived.with_course(@question.course.id)
    @question.update(question_params)

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
    @question.discard

    redirect_to new_course_question_path(@question.course, @question)
  end

  private

  def question_params
    params.require(:question).permit(:course_id, :description, :tried, :location, :user_id, :title, :enrollment_id, tag_ids: [])
  end
end
