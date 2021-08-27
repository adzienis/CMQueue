# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
module QueueAPI
  class Settings < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    resource :settings do
      desc "Get all settings."
      params do
        optional :id, type: Integer
        optional :type, type: String
      end
      get do
        settings = Setting.all
        settings = Setting.accessible_by(current_ability) if current_user
        settings = settings.where(resource_id: params[:id], resource_type: params[:type]) if params[:type] && params[:id]
        settings = settings.where(resource_id: params[:course_id], resource_type: "Course") if params[:course_id]
        settings.as_json methods: :metadata
      end
    end
  end
end
