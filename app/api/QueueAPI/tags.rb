# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
module QueueAPI
  class Tags < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    namespace :courses do
      route_param :course_id do

        desc "Get tags."
        resource :tags do
          get do
            tags = Tag.undiscarded
            tags = tags.accessible_by(current_ability) if current_user
            tags = tags.where(course_id: params[:course_id]) if params[:course_id]

            tags
          end
        end
      end
    end
  end
end
