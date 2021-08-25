# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
module QueueAPI
  class Settings < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    resource :settings do
      desc "Get all settings values."
      params do
        optional :user_id, type: Integer
        optional :course_id, type: Integer
        optional :id, type: Integer
        optional :type, type: String
      end
      get do
        settings = Setting.all
        settings = Setting.accessible_by(current_ability) if current_user
        settings = settings.where(resource_id: params[:id], resource_type: params[:type])
        settings
      end
    end
  end
end
