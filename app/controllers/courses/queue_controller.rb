class Courses::QueueController < ApplicationController
  def show
    authorize! :staff_queue, @course

    redirect_to user_enrollments_path and return unless @course
    redirect_to new_course_forms_question_path(@course) if current_user.has_role?(:student, @course)

    @questions = @course.questions
    @user_question = current_user.courses.find(@course.id).questions.first
    @tags = Tag.all.where(course_id: @course.id).where(archived: false)

    @question = current_user.active_question

    @available_tags = @course.available_tags

    @enrollment = Enrollment.undiscarded.joins(:role).find_by(user_id: current_user.id, "roles.resource_id": @course.id)
  end
end
