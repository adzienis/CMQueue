class Courses::Queue::StaffLogController < ApplicationController
  def current_ability
    @current_ability ||= ::CourseAbility.new(current_user,{
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def show
    authorize! :read, :staff_log
    @date = Date.parse(params[:date]) if params[:date].present?
  end
end
