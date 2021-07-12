# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :set_course, :authenticate_user!

  def set_course
      @course = Course.accessible_by(current_ability).find(params[:course_id]) if params[:course_id]
      @enrollment = Enrollment.undiscarded.joins(:role)
                              .find_by(user_id: current_user.id, "roles.resource_id": @course.id) if params[:course_id]
  end



  def new_session_path(_scope)
    new_user_session_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    landing_path
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || user_enrollments_path
  end

  def swagger; end
end
