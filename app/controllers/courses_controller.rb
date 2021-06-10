class CoursesController < ApplicationController
  load_and_authorize_resource

  def edit
    @course = Course.find(params[:course_id])
  end

  def show
    @course = current_user.courses.find_by(id: params[:course_id])
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

  def answer_page
    @course = Course.find(params[:course_id])
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

  def course_info
    @course = Course.find(params[:course_id])
  end

  def update
    @course = Course.find(params[:course_id])
    @course.update(course_params)

    redirect_to courseInfo_course_path(@course)
  end

  def queues
    @course = Course.find(params[:course_id])

    @tags = Course.find(params[:course_id]).tags.order('tags.created_at DESC')

    @tags_ransack = @tags.ransack(params[:q])

    @pagy, @records = pagy @tags_ransack.result

  end

  def roster
    @course = Course.find(params[:course_id])

    @users_ransack = @course.users.with_any_roles(:student, :ta).distinct.ransack(params[:q])

    @pagy, @records = pagy(@users_ransack.result)
  end

  private

  def course_params
    params.require(:course).permit(:name, :course_id, :status, :ta_code, :instructor_code, :open)
  end

  def answer_params
    params.require(:answer).permit(:id, :course_id, :state, :user_id)
  end

end
