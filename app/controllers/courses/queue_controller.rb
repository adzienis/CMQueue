class Courses::QueueController < ApplicationController
  before_action :authorize

  def authorize
    authorize! :queue_show, @course
  end

  def current_ability
    @current_ability ||= ::CourseAbility.new(current_user, {
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def show
    redirect_to user_enrollments_path and return unless @course
    redirect_to new_course_forms_question_path(@course) if current_user.has_role?(:student, @course)
    redirect_to answer_course_path(@course) if current_user.handling_question?(course: @course)
  end
end
