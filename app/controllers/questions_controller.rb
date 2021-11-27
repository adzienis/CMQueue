# frozen_string_literal: true

class QuestionsController < ApplicationController
  load_and_authorize_resource id_param: :question_id
  respond_to :html, :json, :csv

  def current_ability
    @current_ability ||= ::QuestionAbility.new(current_user,{
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def new
    redirect_to queue_course_path(current_user.active_question.course) if current_user.active_question?

    @question = Question.new(enrollment: @enrollment)
    @available_tags = @course.available_tags
  end

  def position
    @questions = Question.all
    @questions = @questions.undiscarded
    @questions = @questions.with_courses(params[:course_id]) if params[:course_id]
    @questions = @questions.with_users(params[:user_id]) if params[:user_id]
    @questions = @questions.questions_by_state(JSON.parse(params[:state])) if params[:state]

    respond_with @questions.pluck(:id).index(params[:question_id].to_i)
  end

  def index
    @questions = @questions.undiscarded.order(:created_at) #.order("max(question_states.state) desc").group("questions.id")
    @questions = @questions.with_courses(params[:course_id]) if params[:course_id]
    @questions = @questions.with_users(params[:user_id]) if params[:user_id]
    if params[:tags].present?
      tags = JSON.parse(params[:tags])
      @questions = @questions.joins(:tags).where(tags: tags) if tags.present?
    end
    @questions = @questions.by_state(JSON.parse(params[:state])) if params[:state]

    @questions = @questions.count if params[:agg] == "count"

    respond_with @questions
  end

  def previous_questions
    @questions = Question.accessible_by(current_ability)
    @question = @questions.find(params[:question_id])
    @questions = @questions.with_courses(params[:course_id]) if params[:course_id]
    @questions = @questions.with_users(params[:user_id]) if params[:user_id]

    @questions = @questions.previous_questions(@question).order(created_at: :desc).accessible_by(current_ability).undiscarded
    @questions_ransack = @questions.ransack(params[:q])

    @pagy, @records = pagy @questions_ransack.result

    respond_with @questions
  end

  def edit
  end

  def show
    respond_with @question do |format|
      format.json { render json: @question.as_json(include: [:user, :tags, :question_state]) }
    end
  end

  def create
    @question = Question.create(question_params)

    respond_with @question
  end

  def update_state
    @question = Question.accessible_by(current_ability).find(params[:question_id])
    @enrollment = current_user.enrollment_in_course(@course)

    if params[:state] == "resolved"
      # update state to resolved with last staff that interacted
      @question.transition_to_state("resolved",
                                    @question.question_state.enrollment_id,
                                    description: "resolved self")
    else
      @question.transition_to_state(params[:state], current_user.enrollment_in_course(@course).id)
    end
  end

  def download_form
  end

  def update
    @available_tags = Tag.undiscarded.unarchived.with_courses(@question.course.id)
    @question.update(question_params)

    respond_with @question, location: search_course_questions_path(@question.course)
  end

  def paginated_previous_questions
    @question = @questions.find(params[:question_id])
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
    params.require(:question).permit(:course_id,
                                     :description,
                                     :tried,
                                     :location,
                                     :user_id,
                                     :title,
                                     :enrollment_id,
                                     :notes,
                                     question_state_attributes: [:id, :state],
                                     tag_ids: [])
  end
end
