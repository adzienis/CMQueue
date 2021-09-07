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

          desc "Get number of questions associated with tags"
          params do
            optional :tags, type: Object, coerce_with: ->(val) {
              Array(JSON.parse(val))
            }
            optional :state, type: Object, coerce_with: ->(val) {
              Array(JSON.parse(val))
            }
          end
          get 'count' do
            # Tag.all.with_course(1).undiscarded.joins(:questions).group(:id).count

            tags = Tag.accessible_by(current_ability)
            tags = tags.with_course(params[:course_id])
            tags = tags.undiscarded
            tags = tags.joins(:questions).merge(Question.by_state(params[:state])) if params[:state]
            tags = tags.where(id: params[:tags]) if params[:tags]
            tags = tags.group(:id).count

          end
        end


      end
    end
  end
end
