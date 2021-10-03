require "application_responder"

# frozen_string_literal: true

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder


  rescue_from CanCan::AccessDenied do |exception|
    render inline: "Access Denied", status: 403
  end


  include Pagy::Backend

  before_action :authenticate_user!, :set_course, :set_user,  :restrict_routes

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
      raise CanCan::AccessDenied unless current_user.enrolled_in_course?(@course) if @course
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

  protected
  def authenticate_user!
    if user_signed_in?
      super
    else
      redirect_to root_path
      ## if you want render 404 page
      ## render :file => File.join(Rails.root, 'public/404'), :formats => [:html], :status => 404, :layout => false
    end
  end
end
