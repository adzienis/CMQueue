class Courses::OpenController < ApplicationController
  include CourseScoped
  respond_to :json

  def index
    @courses = Course.accessible_by(current_ability).where(open: params[:open])

    respond_with @courses
  end

  def update
    @course.update(open_params)

    respond_with @course.open
  end

  def show
    @course.open
    respond_with @course.open
  end

  private

  def open_params
    params.require(:course).permit(:open)
  end
end
