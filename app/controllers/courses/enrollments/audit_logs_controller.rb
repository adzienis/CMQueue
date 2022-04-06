class Courses::Enrollments::AuditLogsController < ApplicationController

  def current_ability
    @current_ability ||= Courses::EnrollmentAbility.new(current_user, {
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def index
    @enrollment = Enrollment.accessible_by(current_ability, :audit).find(params[:enrollment_id])

    authorize! :audit, Enrollment
  end
end
