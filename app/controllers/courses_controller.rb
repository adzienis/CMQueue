# frozen_string_literal: true

class CoursesController < ApplicationController
  load_and_authorize_resource id_param: :course_id

  def edit
    @course = Course.unscoped.find(params[:course_id])
  end

  def database
  end

  def queue
    redirect_to user_enrollments_path and return unless @course
    redirect_to new_course_question_path(@course) if current_user.active_question.nil? && current_user.has_role?(:student, @course)

    redirect_to answer_course_path(@course) and return if current_user.question_state&.state == 'resolving'

    @questions = @course.questions
    @user_question = current_user.courses.find(@course.id).questions.first
    @tags = Tag.all.where(course_id: @course.id).where(archived: false)

    @question = current_user.active_question

    @available_tags = @course.available_tags

    @enrollment = Enrollment.undiscarded.joins(:role).find_by(user_id: current_user.id, "roles.resource_id": @course.id)
  end

  def show
    @course = Course.accessible_by(current_ability).select(current_ability.permitted_attributes(:read, @course)).find(params[:course_id])

    raise CanCan::AccessDenied and return unless current_user.has_any_role?({ name: :ta, resource: @course}, {name: :instructor, resource: @course})
  end

  def answer_page
    question_state = current_user.question_state
    @top_question = question_state&.question
  end

  def new
    @course = Course.new
  end

  def index
    @courses = Course.unscoped.accessible_by(current_ability)
    @courses_ransack = @courses.order("courses.created_at": :desc)
    @courses_ransack = @courses_ransack.where(course_id: params[:course_id]) if params[:course_id]
    @courses_ransack = @courses_ransack.with_user(params[:user_id]) if params[:user_id]

    @courses_ransack = @courses_ransack
                           .joins(:enrollments)
                           .includes(:enrollments)
    @courses_ransack = @courses_ransack.ransack(params[:q])

    @pagy, @records = pagy @courses_ransack.result
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

  def course_info
  end

  def update
    @course.update(course_params)

    render turbo_stream: (turbo_stream.update @course, partial: "shared/edit_form", locals: { model_instance: @course }) and return unless @course.errors.count == 0

    redirect_to course_path(@course)
  end

  def queues
    @tags = Course.find(params[:course_id]).tags.order('tags.created_at DESC')

    @tags_ransack = @tags.ransack(params[:q])

    @pagy, @records = pagy @tags_ransack.result
  end

  def roster
    @users_ransack = @course.users.with_any_roles(:student, :ta).distinct.ransack(params[:q])

    @pagy, @records = pagy(@users_ransack.result)
  end

  private

  def course_params
    params.require(:course).permit(:name, :status, :ta_code, :instructor_code, :open, :course_code, :student_code)
  end

  def answer_params
    params.require(:answer).permit(:id, :state, :user_id)
  end
end
