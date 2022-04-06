class Courses::Queue::FeedsController < ApplicationController

  before_action :authorize

  def authorize
    authorize! :queue_show, @course
  end

  def current_ability
    @current_ability ||= ::CourseAbility.new(current_user, {
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def show
  end
end
