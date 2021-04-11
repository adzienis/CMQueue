class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def new_session_path(scope)
    new_user_session_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    landing_path
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || user_courses_path
  end
end
