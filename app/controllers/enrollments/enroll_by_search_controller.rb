class Enrollments::EnrollBySearchController < ApplicationController
  def new
    @enrollment = Enrollment.new
  end

  def create
    render head status: 400 and return unless enroll_by_search_params[:course_id]

    @course = Course.find(enroll_by_search_params[:course_id])

    @enrollment = current_user.enrollments.build(course: @course, role: @course.student_role)

    if @enrollment.save
      flash.now[:success] = "Successfully enrolled in #{@course.name} as a #{@enrollment.role.name}"
    end

  end

  private

  def enroll_by_search_params
    params.require(:enrollment).permit(:course_id)
  end

end
