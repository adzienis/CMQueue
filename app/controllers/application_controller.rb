# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :set_course, :set_user, :authenticate_user!, :restrict_routes

  def current_ability
    @current_ability ||= Ability.new(current_user, params)
  end

  def set_user
    @user = User.accessible_by(current_ability).find(params[:user_id]) if params[:user_id]
  end

  def restrict_routes
    if request.path.include?('users/')
      raise CanCan::AccessDenied unless current_user.id == params[:user_id].to_i if params[:user_id]
    elsif request.path.include?('courses/')
      raise CanCan::AccessDenied unless current_user.enrolled_in_course?(params[:course_id]) if params[:course_id]
    end
  end

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
    stored_location_for(resource_or_scope) || current_user_enrollments_path
  end

  def swagger; end
end
