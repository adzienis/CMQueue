class Users::EnrollmentsController < ApplicationController
  respond_to :html, :json

  def index
    @courses = current_user.courses.with_role params[:role], current_user if params[:role] && params[:user_id]
    @courses = current_user.courses unless params[:role]

    respond_to do |format|
      format.html
      format.json { render json: @courses }
    end
  end

  def create
    enroll_by_code = Forms::EnrollByCode.new(enrollment_params[:code], current_user)

    enroll_by_code.save

    respond_with enroll_by_code
  end

  def destroy
    @enrollment = current_user.enrollments.undiscarded.joins(:role).find_by("roles.resource_id": Course.find(params[:id])).discard

    respond_to do |format|
      format.html
      format.json {
        render json: @enrollment
      }
    end
  end

  private

  def enrollment_params
    params.require(:enrollment).permit(:course_id, :code)
  end
end
