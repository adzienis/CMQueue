class EnrollmentsController < ApplicationController
  def index
    @courses = current_user.courses.with_role params[:role], current_user if params[:role] && params[:user_id]
    @courses = current_user.courses unless params[:role]

    @course = Course.find(params[:course_id]) if params[:course_id]

    @enrollments_ransack = Enrollment.ransack(params[:q])

    @pagy, @records = pagy @enrollments_ransack.result

    respond_to do |format|
      format.html
      format.json { render json: @courses }
    end
  end

  def show
    @enrollment = Enrollment.find(params[:id])
  end

  def create
    if enrollment_params[:code]
      ta_course = Course.find_by(ta_code: enrollment_params[:code])
      instructor_course = Course.find_by(instructor_code: enrollment_params[:code])

      if ta_course
        current_user.courses << ta_course
        current_user.add_role :ta, ta_course
        Enrollment.find_by(user_id: current_user.id, course_id: ta_course.id).update(role_id: Role.find_by(resource_id: ta_course.id, name: :ta).id)
        @course = ta_course
      end
      if instructor_course
        current_user.courses << instructor_course
        current_user.add_role :instructor, instructor_course
        Enrollment.find_by(user_id: current_user.id, course_id: instructor_course.id).update(role_id: Role.find_by(resource_id: instructor_course.id, name: :instructor).id)
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
      current_user.courses << @course
      current_user.add_role :student, @course
      Enrollment.find_by(user_id: current_user.id, course_id: @course.id).update(role_id: Role.find_by(resource_id: @course.id, name: :student).id)
    end

    if @course and @course.errors.any?
      render json: @course.errors.messages.to_json, status: :unprocessable_entity
      return
    end
    render json: {}
  end

  def destroy
    @enrollment = current_user.courses.destroy(Course.find(params[:id]))

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
