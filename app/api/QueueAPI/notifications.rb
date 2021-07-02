# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
module QueueAPI
  class Notifications < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    namespace :questions do

      route_param :question_id do
        resource :notifications do
          desc 'Get all notifications associated with a question.'
          get do

            notifications = Question.accessible_by(current_ability).find(params[:question_id]).notifications
            notifications
          end
        end

      end
    end

    namespace :users do
      route_param :user_id do
        resource :notifications do

          desc 'Get all notifications associated with a user'
          get do
            notifications = User.accessible_by(current_ability).find(params[:user_id]).notifications
            notifications
          end
        end


        resource :unread_notifications do

          desc 'Get all notifications associated with a user'
          get do
            notifications = User.accessible_by(current_ability).find(params[:user_id]).notifications.unread
            notifications
          end
        end
      end
    end

    namespace :notifications do
      route_param :notification_id do


        desc 'Mark a notification as read'
        params do
          requires :notification_id, type: Integer
        end
        post 'mark_as_read' do
          Notification.find(params[:notification_id]).mark_as_read!
        end
      end
    end
  end
end
