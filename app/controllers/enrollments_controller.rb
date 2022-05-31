# frozen_string_literal: true

class EnrollmentsController < ApplicationController
  load_and_authorize_resource id_param: :enrollment_id

  respond_to :html

  def current_ability
    @current_ability ||= EnrollmentAbility.new(current_user, {
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def index
    @enrollments = @enrollments
      .undiscarded
      .joins(:user, :role, :course)
      .order("enrollments.created_at": :desc)
    @enrollments = @enrollments.where(user_id: params[:user_id]) if params[:user_id]
    @enrollments = @enrollments.with_course_roles(JSON.parse(params[:role])) if params[:role]
  end
end
