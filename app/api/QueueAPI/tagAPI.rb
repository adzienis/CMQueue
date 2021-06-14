
require 'doorkeeper/grape/helpers'
module QueueAPI

  class TagAPI < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    namespace 'courses/:course_id' do
      resource :tags do
        get do
          tags = Tag.accessible_by(current_ability).where(course_id: params[:course_id]) if params[:course_id]

          tags
        end
      end
    end

    resource :tags do

    end
  end
end