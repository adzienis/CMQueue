module Notifications
  class NotificationsComponent < ViewComponent::Base
    def initialize(current_user:)
      @current_user = current_user
    end

    private

    def render?
      current_user.present?
    end

    attr_reader :current_user
  end
end
