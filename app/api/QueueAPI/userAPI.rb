module QueueAPI

  module Helpers

    def current_ability
      # instead of Ability.new(current_user)
      @current_ability ||= Ability.new(current_user)
    end

    def current_user
      warden = env["warden"]
      warden.authenticate
    end
  end

  class UserAPI < Grape::API
    helpers Helpers

    desc 'Returns pong.'
    get :users do
      Question.accessible_by(current_ability)
    end
  end
end