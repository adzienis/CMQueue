class Courses::QueueController < ApplicationController
  before_action :authorize

  def authorize
    authorize! :queue_show, @course
  end

  def current_ability
    @current_ability ||= ::CourseAbility.new(current_user,{
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def show

    redirect_to user_enrollments_path and return unless @course
    redirect_to new_course_forms_question_path(@course) if current_user.has_role?(:student, @course)

    @questions = @course.questions
    @user_question = current_user.courses.find(@course.id).questions.first
    @tags = Tag.all.where(course_id: @course.id).where(archived: false)

    @question = current_user.active_question

    @available_tags = @course.available_tags

    @enrollment = Enrollment.undiscarded.joins(:role).find_by(user_id: current_user.id, "roles.resource_id": @course.id)
    @pagy, @records = pagy(@course.questions_on_queue)
  end
end
