require "application_responder"

# frozen_string_literal: true

class ApplicationController < ActionController::Base
  impersonates :user
  self.responder = ApplicationResponder

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        render inline: "Access Denied", status: 401
      end
      format.json do
        render json: false, status: 401
      end
    end
  end

  include Pagy::Backend

  before_action :authenticate_user!, :set_course, :set_user, :set_enrollment, :set_semester

  def set_variant
    agent = request.user_agent
    return request.variant = :tablet if /(tablet|ipad)|(android(?!.*mobile))/i.match?(agent)
    return request.variant = :mobile if /Mobile/.match?(agent)
    request.variant = :desktop
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, {
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def set_user
    if params[:user_id]
      @user = User.accessible_by(UserAbility.new(current_user, {
        params: params,
        path_parameters: request.path_parameters
      })).find_by(id: params[:user_id])
    end
  end

  def set_course
    @course = Course.find_by(id: params[:course_id]) if params[:course_id]
  end

  def set_enrollment
    @current_enrollment = current_user.enrollment_in_course(@course) if @course.present?

    if request.path_parameters[:course_id].present? && @current_enrollment.nil?
      raise CanCan::AccessDenied
    end
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

  def swagger
  end

  protected

  def set_semester
    if @course.present?
      session["course_#{@course.id}"] ||= {}
      session["course_#{@course.id}"]["semester"] ||= Enrollment.default_semester
      @current_semester = session["course_#{@course.id}"]["semester"]
    end
  end

  def authenticate_user!
    if user_signed_in?
      super
    else
      redirect_to root_path, flash: {error: "Token has expired. You have been signed out."}
      ## if you want render 404 page
      ## render :file => File.join(Rails.root, 'public/404'), :formats => [:html], :status => 404, :layout => false
    end
  end
end
