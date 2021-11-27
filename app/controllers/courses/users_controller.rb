class Courses::UsersController < ApplicationController
  respond_to :html

  def new
    @user = User.new
  end

  def create
    @user = User.create(user_params)

    respond_with @course, @user, location: new_course_enrollment_path(@course)
  end

  private

  def user_params
    params.require(:user).permit(:given_name, :family_name, :email)
  end

end
