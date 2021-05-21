class UsersController < ApplicationController
  def index
  end

  def enrollments

  end

  def show
    @course = Course.find(params[:course_id])
    @user = User.find(params[:id])

    if @user.has_role?(:ta, @course)
      @questions = QuestionState.left_joins(:user).where("users.id": @user.id).includes(:question).where("question_states.state": "resolved")
    else
      @questions = QuestionState.left_joins(:user).where("users.id": @user.id).includes(:question).where("question_states.state": ["resolved", "kicked", "frozen"])
    end
  end
end
