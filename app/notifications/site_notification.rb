# To deliver this notification:
#
# SiteNotification.with(post: @post).deliver_later(current_user)
# SiteNotification.with(post: @post).deliver(current_user)

class SiteNotification < Noticed::Base
  deliver_by :database, if: :site?
  deliver_by :action_cable, channel: NotificationChannel, format: :to_action_cable, if: :notifications?

  def notifications?
    !!recipient.settings.option_value_of_key("desktop_notifications")
  end

  def site?
    !!params[:site]
  end

  def to_action_cable
    {
      type: self.class.name,
      params: params,
    }
  end

  def self.success(target, message, delay = nil)
    if delay
      SiteNotification.with(type: "success", message: message, title: "Success", delay: delay).deliver_later(target)
    else
      SiteNotification.with(type: "success", message: message, title: "Success").deliver_later(target)
    end
  end

  def self.student_on_queue(target, delay = nil)
    if delay
      SiteNotification.with(type: "success", message: message, title: "Success", delay: delay).deliver_later(target)
    else
      SiteNotification.with(type: "success", message: message, title: "Success").deliver_later(target)
    end
  end

  def self.failure(target, message, delay = nil)
    if delay
      SiteNotification.with(type: "failure", message: message, title: "Failure", delay: delay).deliver_later(target)
    else
      SiteNotification.with(type: "failure", message: message, title: "Failure").deliver_later(target)
    end
  end

  after_deliver do
    ClearNotificationJob.set(wait: params[:delay].seconds).perform_later(record.id) if params.key? :delay
  end
end
