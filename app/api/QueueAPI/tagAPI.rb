module QueueAPI

  class TagAPI < Grape::API
    helpers Helpers

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