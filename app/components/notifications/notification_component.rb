module Notifications
  class NotificationComponent < ViewComponent::Base
    def initialize(notification:)
      super
      @notification = notification
    end

    def message
      notification.params[:message]
    end

    private

    attr_reader :notification
  end
end
