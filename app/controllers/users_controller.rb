class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @course = Course.find(params[:course_id]) if params[:course_id]

    @users_ransack = User.ransack(params[:q])

    @pagy, @records = pagy @users_ransack.result
  end

  def enrollments

  end

  def show
    @course = Course.find(params[:course_id]) if params[:course_id]
    @user = User.find(params[:id])

    if params[:course_id] && @user.has_role?(:ta, @course)
      @questions = QuestionState.left_joins(:user).where("users.id": @user.id).includes(:question).where("question_states.state": "resolved")
    else
      @questions =  QuestionState
                      .joins(:question)
                      .joins("inner join users on users.id = questions.user_id")
                      .where("users.id = ?", @user.id)
                      .where("question_states.id = (select max(question_states.id) from question_states where question_states.question_id = questions.id)")
      @unique_questions = @questions

      @unique_questions_count = @questions.select("distinct questions.id").count
    end
  end
end
