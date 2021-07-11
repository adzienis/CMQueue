# frozen_string_literal: true

class BaseAPI < Grape::API
  include Rails.application.routes.url_helpers

  def self.inherited(subclass)
    super

    subclass.class_eval do

      rescue_from Grape::Exceptions::ValidationErrors do |e|
        error!(e, 400)
      end

      rescue_from :all

      rescue_from ActiveRecord::RecordInvalid do |e|
        error!(e.record.errors, 400)
      end

      rescue_from ActiveModel::ValidationError do |e|
        error!(e, 400)
      end

      rescue_from NoMethodError do |e|
        error!(e, 400)
      end

      rescue_from CanCan::AccessDenied do |e|
        error!(e, 400)
      end

      before do
        doorkeeper_authorize! if doorkeeper_token
      end

      helpers do

        def authorize_route_for_current_user(action, resource = nil) end

        def authorize!(*args)
          ::Ability.new(current_user).authorize!(*args)
        end

        def current_ability
          current_ability ||= Ability.new(current_user)
          current_ability
        end

        def current_user
          doorkeeper_token&.try(:resource_owner_id)
          warden = env['warden']
          current_user = warden&.authenticate

          error!('Unauthorized', 401) unless (current_user || doorkeeper_token)

          current_user
        end
      end
    end
  end
end
