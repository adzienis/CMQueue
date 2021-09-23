class NotificationsController < ApplicationController
  load_and_authorize_resource

  respond_to :html, :json

  def index
    @notifications = Notification.all
    @notifications = @notifications.with_user(@user.id) if params[:user_id]
    @notifications = @notifications.with_course(@course.id) if params[:course_id]
    @notifications = @notifications.unread if params[:unread] == "true"
    @notifications = @notifications.read if params[:unread] == "false"

    respond_with @notifications
  end

  def show
  end
end