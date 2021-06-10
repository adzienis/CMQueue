module QueueAPI

  class EnrollmentAPI < Grape::API
    helpers Helpers

    namespace 'users/:user_id' do
      resource :enrollments do
        get do
          courses = current_user.courses.with_role params[:role], current_user if params[:role]
          courses = current_user.courses unless params[:role]

          courses
        end
      end
    end

    resource :tags do

    end
  end
end