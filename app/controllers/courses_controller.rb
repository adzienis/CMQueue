# frozen_string_literal: true

class CoursesController < ApplicationController
  load_and_authorize_resource id_param: :course_id

  respond_to :html, :json

  include ResourceInitializable
  include ResourceAuthorizable
  include NameFilterable

  def edit
    @course = Course.unscoped.find(params[:course_id])
  end

  def top_question
    top_question = Question.undiscarded
    top_question = top_question.latest_by_state("resolving")
    top_question = top_question.with_courses(@course.id).first

    respond_with top_question and return if top_question.nil?

    authorize! :read, top_question

    respond_with top_question  do |format|
      format.json { render json: top_question.as_json(include: [:user, :tags, :question_state])}
    end
  end

  def show
    redirect_to new_course_question_path(@course) and return unless current_user.has_any_role?({ name: :ta, resource: @course}, {name: :instructor, resource: @course})
  end

  def new
    @course = Course.new
  end

  def index
    @courses = Course.accessible_by(current_ability)
    @courses = @courses.order("courses.created_at": :desc)
    @courses = @courses.where(course_id: params[:course_id]) if params[:course_id]
    @courses = @courses.with_user(params[:user_id]) if params[:user_id]

    @courses_ransack = @courses.ransack(params[:q])

    @pagy, @records = pagy @courses_ransack.result

    respond_with @courses
  end

  def semester
    session[:semester] = params[:semester]

    redirect_to request.referer
  end

  def create
    @course = Course.create(course_params)

    # should refactor into a form object
    current_user.add_role :instructor, @course

    render turbo_stream: (turbo_stream.replace @course, partial: "shared/new_form", locals: { model_instance: @course,options: {
      except: [:settings,
               :roles,
               :enrollments,
               :users,
               :questions,
               :unresolved_questions,
               :active_questions,
               :tags,
               :access_grants,
               :access_tokens,
               :applications,]
    }  }) and return unless @course.errors.count == 0

    redirect_to user_courses_path(@current_user)
  end

  def update
    @course.update(course_params)

    render turbo_stream: (turbo_stream.update @course, partial: "shared/edit_form", locals: { model_instance: @course }) and return unless @course.errors.count == 0

    redirect_to course_path(@course)
  end

  private

  def course_params
    params.require(:course).permit(:name, :status, :ta_code, :instructor_code, :open, :course_code, :student_code)
  end

  def answer_params
    params.require(:answer).permit(:id, :state, :user_id)
  end
end
