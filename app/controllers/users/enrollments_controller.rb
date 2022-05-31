class Users::EnrollmentsController < ApplicationController
  respond_to :html
  load_and_authorize_resource id_param: :enrollment_id

  def current_ability
    @current_ability ||= EnrollmentAbility.new(current_user, {
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def index
    @courses = current_user.courses.with_role(params[:role], current_user) if params[:role] && params[:user_id]
    @courses = current_user.courses unless params[:role]
  end
end
