# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
module QueueAPI
  class Settings < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    resource :settings do
      desc "Get all settings values."
      params do
        optional :user, type: Integer
        optional :course_id, type: Integer
      end
      get do
        settings = Setting.all
        settings = Setting.accessible_by(current_ability) if current_user
        settings = settings.where(resource_id: params[:user_id], resource_type: "User") if params[:user_id]
        settings = settings.where(resource_id: params[:course_id], resource_type: "Course") if params[:course_id]
        settings
      end
    end
  end
end
