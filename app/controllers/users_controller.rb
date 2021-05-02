class UsersController < ApplicationController
  def index
  end

  def enrollments

  end

  def show
    @user = User.find(params[:id])
    @questions = @user.questions
  end
end
