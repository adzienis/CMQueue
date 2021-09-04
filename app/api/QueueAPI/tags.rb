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
            course = Course.find(params[:course_id])

            tags = course.available_tags.accessible_by(current_ability)
          end
        end

        desc "Selected tags."
        resource :tags do
          get do
            course = Course.find(params[:course_id])

            tags = course.available_tags.accessible_by(current_ability)
          end
        end
      end
    end
  end
end
