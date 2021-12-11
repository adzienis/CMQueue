class Enrollments::EnrollBySearchController < ApplicationController
  def new
    @enrollment = Enrollment.new
  end

  def create
    render head status: 400 and return unless enroll_by_search_params[:course_id]

    @course = Course.find(enroll_by_search_params[:course_id])

    @enrollment = current_user.enrollments.build(role: @course.student_role)

    if @enrollment.save
      flash.now[:success] = "Successfully enrolled in #{@course.name} as a #{@enrollment.role.name}"

      RenderComponentJob.perform_later("Users::Enrollments::EnrollmentsComponent",
                                       current_user,
                                       opts: { target: "student-enrollments" },
                                       component_args: { enrollments: current_user.student_enrollments.to_a })
    end
  end

  private

  def enroll_by_search_params
    params.require(:enrollment).permit(:course_id)
  end
end
