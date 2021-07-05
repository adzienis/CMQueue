# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
module QueueAPI
  class Enrollments < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    resource :users do
      route_param :user_id do
        resource :enrollments do
          get do
            courses = current_user.courses.with_role params[:role], current_user if params[:role]
            courses = current_user.courses unless params[:role]

            courses
          end
        end
      end

    end

    resource :enrollments do

      desc "Enroll a user into a course."
      params do
        optional :code, type: String
        optional :course_id, type: Integer
        requires :user_id, type: Integer
      end
      post scopes: [:admin] do
        user = User.accessible_by(current_ability).find_by(id: params[:user_id])

        error!("User not found", :bad_request) and return unless user

        error!("Unauthorized!", :unauthorized) and return unless authorize! :enroll_user, user

        if params[:code]
          ta_course = Course.find_by(ta_code: params[:code])
          instructor_course = Course.find_by(instructor_code: params[:code])

          if ta_course
            user.add_role :ta, ta_course
          elsif instructor_course
            user.add_role :instructor, instructor_course
          end
        else
          course = Course.find(params[:course_id])
          user.add_role :student, course
        end

      end

      params do
        optional :user_id, type: Integer
        optional :course_id, type: Integer
      end
      get do
        enrollments = Enrollment.undiscarded.accessible_by(current_ability)
        enrollments = enrollments.where(user_id: params[:user_id]) if params[:user_id]
        enrollments = enrollments.joins(:role).where("roles.resource_id": params[:course_id], "roles.resource_type": "Course") if params[:course_id]
        enrollments = enrollments.order(created_at: :desc).first if params[:most_recent]

        enrollments
      end

      get do

      end

      route_param :id do
        delete scopes: [:write] do
          enrollment = Enrollment.find(params[:id])

          error!("Unauthorized!", :unauthorized) and return unless authorize! :delete, enrollment

          enrollment.discard
        end
      end
    end

    resource :tags do
    end
  end
end