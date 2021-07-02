# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
module QueueAPI
  class Settings < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    resource :settings do

      get do
        settings = Setting.all
        settings = settings.where(resource_id: params[:user_id], resource_type: "User") if params[:user_id]
        settings
      end
    end
  end
end
