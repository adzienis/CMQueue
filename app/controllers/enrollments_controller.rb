# frozen_string_literal: true

class EnrollmentsController < ApplicationController
  def index
    @course = Course.find(params[:course_id]) if params[:course_id]

    @enrollments_ransack = Enrollment.undiscarded.order(updated_at: :desc)
    @enrollments_ransack = @enrollments_ransack.joins(:role).where("roles.resource_id": params[:course_id]) if params[:course_id]

    @enrollments_ransack = @enrollments_ransack.ransack(params[:q])

    @pagy, @records = pagy @enrollments_ransack.result

    respond_to do |format|
      format.html
      format.js { render inline: "window.open('#{URI::HTTP.build(path: "#{request.path}.csv", query: request.query_parameters.to_query, format: :csv)}', '_blank')"}
      format.csv { send_data helpers.to_csv(params[:enrollment].to_unsafe_h, @enrollments_ransack.result, Enrollment), filename: "test.csv" }
    end
  end

  def import
    course = Course.find(params[:course_id])
    CSV.foreach(params[:csv_file], headers: true) do |row|
      user = User.find_or_create_by!(row.to_hash)
      user.add_role :student, course
    end

    SiteNotification.with(type: "Success", body: "Successfully imported file.", title: "Success", delay: 2).deliver(current_user)

    redirect_to request.referer
  end

  def download_form

  end

  def show
    @course = Course.find(params[:course_id]) if params[:course_id]
    @enrollment = Enrollment.find(params[:id])
  end

  def create
    if enrollment_params[:code]
      ta_course = Course.find_by(ta_code: enrollment_params[:code])
      instructor_course = Course.find_by(instructor_code: enrollment_params[:code])

      if ta_course
        # current_user.courses << ta_course
        current_user.add_role :ta, ta_course
        current_user.enrollments.create!(
          semester_id: Semester.find_by(name: Semester.default_semester,
                                        course_id: ta_course.id).id, role_id: Role.find_by(resource_id: ta_course.id, name: 'ta').id
        )

        # Enrollment.find_by(user_id: current_user.id, course_id: ta_course.id).update(role_id: Role.find_by(resource_id: ta_course.id, name: :ta).id)
        @course = ta_course
      end
      if instructor_course
        # current_user.courses << instructor_course
        current_user.add_role :instructor, instructor_course

        current_user.enrollments.create!(
          semester_id: Semester.find_by(name: Semester.default_semester,
                                        course_id: ta_course.id).id, role_id: Role.find_by(resource_id: ta_course.id, name: 'instructor').id
        )
        @course = instructor_course
      end

      respond_to do |format|
        format.html
        format.json do
          if @course
            render json: @course
          else
            render json: { course: ["Can't find course"] }, status: :unprocessable_entity
          end
        end
      end
      return
    else
      @course = Course.find(enrollment_params[:course_id])
      # current_user.courses << @course
      current_user.add_role :student, @course

      current_user.enrollments.create!(
        semester_id: Semester.find_by(name: Semester.default_semester,
                                      course_id: ta_course.id).id, role_id: Role.find_by(resource_id: ta_course.id, name: 'student').id
      )
    end

    if @course&.errors&.any?
      render json: @course.errors.messages.to_json, status: :unprocessable_entity
      return
    end
    render json: {}
  end

  def destroy
    @enrollment = current_user.enrollments.undiscarded.joins(:role).find_by("roles.resource_id": Course.find(params[:id])).discard

  end

  private

  def enrollment_params
    params.require(:enrollment).permit(:course_id, :code)
  end
end
