class Users::CoursesController < ApplicationController
  def show
  end

  def index
    @peep ||= false
    @courses ||= current_user.courses
    @searched_courses ||= []
  end

  def new
    @course = Course.new
  end

  def create
    @user = User.find(current_user.id)
    @course = Course.create(course_params)
    redirect_to user_courses_path
  end

  private

  def course_params
    params.require(:course).permit(:name)
  end
end
