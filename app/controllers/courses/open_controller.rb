class Courses::OpenController < ApplicationController
  respond_to :json, :html


  def current_ability
    @current_ability ||= ::CourseAbility.new(current_user,{
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def index
    @courses = Course.accessible_by(current_ability).where(open: params[:open])

    respond_with @courses
  end

  def update
    authorize! :open, @course

    @course.update(open_params)

    respond_with @course
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
