
require 'doorkeeper/grape/helpers'
module QueueAPI

  class UserAPI < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    desc 'Returns users'
    get :users do
      @users = User.accessible_by(current_ability)
      @users = @users.joins(:enrollments).where("enrollments.course_id": params[:course_id]) if params[:course_id]
      @users = @users.joins(enrollments: :roles).where("roles.state": params[:role]) if params[:role]
    end
  end
end