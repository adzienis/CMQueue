# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
module QueueAPI
  class Users < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    desc 'Returns users'
    get :users do
      @users = User.accessible_by(current_ability)
      @users = @users.joins(:enrollments).where("enrollments.course_id": params[:course_id]) if params[:course_id]
      @users = @users.joins(enrollments: :role).where("roles.name": params[:role]) if params[:role]

      @users
    end
  end
end
