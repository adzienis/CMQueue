class Notifications::ReadController < ApplicationController
  respond_to :html, :json

  def update
    @notification = Notification.find(params[:notification_id])

    @notification.mark_as_read!
  end
end
