class Users::EnrollmentsController < ApplicationController
  def index



    @courses = current_user.courses.with_role params[:role], current_user if params[:role] && params[:user_id]
    @courses = current_user.courses unless params[:role]

    respond_to do |format|
      format.html
      format.json { render json: @courses }
    end
  end

  def create
    if enrollment_params[:code]
      ta_course = Course.find_by(ta_code: enrollment_params[:code])
      instructor_course = Course.find_by(instructor_code: enrollment_params[:code])

      if ta_course
        head :conflict and return if current_user.has_role? :ta, ta_course
        current_user.add_role :ta, ta_course
        @course = ta_course
      end
      if instructor_course
        head :conflict and return if current_user.has_role? :student, instructor_course
        current_user.add_role :instructor, instructor_course
        @course = instructor_course
      end

      respond_to do |format|
        format.html
        format.json {
          if @course
            render json: @course
          else
            render json: { course: ["Can't find course"] }, status: :unprocessable_entity
          end
        }
      end
      return
    else
      @course = Course.find(enrollment_params[:course_id])

      head :conflict and return if current_user.has_role? :student, @course

      current_user.add_role :student, @course
    end

    if @course and @course.errors.any?
      render json: @course.errors.messages.to_json, status: :unprocessable_entity
      return
    end
    render json: {}
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
