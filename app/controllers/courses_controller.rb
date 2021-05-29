class CoursesController < ApplicationController
  load_and_authorize_resource

  def edit
    @course = Course.find(params[:id])
  end

  def show
    @course = current_user.courses.find_by(id: params[:id])
    unless @course
      redirect_to user_enrollments_path and return
    end

    if current_user.question_state&.state == "resolving"
      redirect_to answer_course_path(@course) and return
    end

    @questions = @course.questions
    @user_question = current_user.courses.find(@course.id).questions.first

    @question = Question.all
                        .left_joins(:question_state, :user)
                        .where("questions.id = ?", current_user.id)
                        .where("question_states.state in (?)", [QuestionState.states["unresolved"], QuestionState.states["frozen"]]).first
    @tags = Tag.all.where(course_id: @course.id).where(archived: false)

    @top_question = current_user.question_state&.question


  end

  def open
    @course = Course.find(params[:id]).update(open: params[:open][:status])

    respond_to do |format|
      format.html
      format.json { render json: @course }
    end
  end

  def open_status
    render json: Course.find(params[:id]).open
  end

  def answer_page
    @course = Course.find(params[:id])
    question_state = current_user.question_state
    @top_question = question_state&.question
  end

  def new
  end

  def index
    @courses = Course.all
  end

  def create

    @course = Course.create(course_params)

    redirect_to courses_path
  end

  def active_tas
    @course = Course.find(params[:id])
    @tas = User.with_role :ta, @course
    @tas = @tas.joins(:question_state).where('question_states.created_at > ?', 15.minutes.ago).distinct

    respond_to do |format|
      format.html
      format.json { render json: @tas, include: :question_state }
    end
  end

  def answer
    @course = Course.find(params[:id])
    ActiveRecord::Base.transaction do

      @top_question = Question.questions_by_state(["unresolved"]).first

      @top_question.question_states.create(state: answer_params[:state], user_id: answer_params[:user_id])

    end

    render json: @top_question
  end

  def course_info
    @course = Course.find(params[:id])

  end

  def search
    @searched_courses ||= []

    respond_to do |format|
      format.html
      format.json { render json: Course.where("name LIKE :name", name: "%#{params[:name]}%") }
    end
  end

  def top_question

    question_state = User.find(params[:user_id]).question_state
    @top_question = question_state&.question

    if question_state&.state == "resolving"
      render json: @top_question, include: [:question_state, :tags, :user]
    else
      render json: nil
    end
  end

  def update

    @course = Course.find(params[:id])
    @course.update(course_params)

    redirect_to settings_course_course_path(@course)
  end

  def queues
    @course = Course.find(params[:id])

    @tags = Course.find(params[:id]).tags.order('tags.created_at DESC')
  end

  def roster
    @course = Course.find(params[:id])

    @users_ransack = @course.users.with_any_roles(:student, :ta).distinct.ransack(params[:q])

    @pagy, @records = pagy(@users_ransack.result)
  end

  private

  def course_params
    params.require(:course).permit(:name, :status, :ta_code, :instructor_code)
  end

  def answer_params
    params.require(:answer).permit(:id, :course_id, :state, :user_id)
  end

end
