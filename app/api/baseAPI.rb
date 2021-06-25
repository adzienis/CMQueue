# frozen_string_literal: true

class BaseAPI < Grape::API
  include Rails.application.routes.url_helpers

  def self.inherited(subclass)
    super

    subclass.class_eval do
      before do
        doorkeeper_authorize! if doorkeeper_token
      end

      helpers do
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
