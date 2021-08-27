# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
module QueueAPI
  class Enrollments < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    resource :users do
      route_param :user_id do

        desc "Gets all the courses associated with the current user."
        params do
          requires :role, type: String
        end
        resource :courses do
          get do
            courses = current_user.courses.with_role params[:role], current_user if params[:role]
            courses = current_user unless params[:role]

            courses
          end
        end

        desc "Gets all the enrollments associated with the current user."
        params do
          requires :role, type: String
        end
        resource :enrollments do
          get do
            courses = current_user.courses.with_role params[:role], current_user if params[:role]
            courses = current_user unless params[:role]

            enrollments = current_user.enrollments.joins(:role).where("roles.resource_id": courses.pluck(:id), "roles.resource_type": "Course")
            enrollments = enrollments.undiscarded
            enrollments.as_json include: [:course, :role]
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

        ::Services::Enrollments::CreateEnrollment
          .new(params[:user_id], params[:course_id], params[:code])
          .set_current_ability(current_ability)
          .perform

      end

      desc "Get enrollments associated with a user."
      params do
        optional :user_id, type: Integer
        optional :course_id, type: Integer
        optional :most_recent, type: Boolean
      end
      get scopes: [:read] do
        enrollments = Enrollment.all.undiscarded
        enrollments = enrollments.accessible_by(current_ability) if current_user

        enrollments = enrollments.where(user_id: params[:user_id]) if params[:user_id]
        enrollments = enrollments.joins(:role).where("roles.resource_id": params[:course_id], "roles.resource_type": "Course") if params[:course_id]
        enrollments = enrollments.order(created_at: :desc).first if params[:most_recent]

        enrollments
      end

      desc "Delete an enrollment"
      route_param :id do
        delete scopes: [:write] do

          ::Services::Enrollments::DeleteEnrollment
            .new(params[:id])
            .set_current_ability(current_ability)
            .perform
        end
      end
    end
  end
end