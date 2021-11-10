# To deliver this notification:
#
# SiteNotification.with(post: @post).deliver_later(current_user)
# SiteNotification.with(post: @post).deliver(current_user)

class SiteNotification < Noticed::Base
  deliver_by :database
  # deliver_by :action_cable, format: :to_action_cable

  def to_action_cable
    {
      type: self.class.name,
      params: params,
    }
  end

  def self.success(target, message, delay = nil)
    if delay
      SiteNotification.with(type: "Success", body: message, title: "Success", delay: delay).deliver_later(target)
    else
      SiteNotification.with(type: "Success", body: message, title: "Success").deliver_later(target)
    end
  end

  def self.student_on_queue(target, delay = nil)
    if delay
      SiteNotification.with(type: "Success", body: message, title: "Success", delay: delay).deliver_later(target)
    else
      SiteNotification.with(type: "Success", body: message, title: "Success").deliver_later(target)
    end
  end

  def self.failure(target, message, delay = nil)
    if delay
      SiteNotification.with(type: "Failure", body: message, title: "Failure", delay: delay).deliver_later(target)
    else
      SiteNotification.with(type: "Failure", body: message, title: "Failure").deliver_later(target)
    end
  end

  after_deliver do
    ClearNotificationJob.set(wait: params[:delay].seconds).perform_later(record.id) if params.key? :delay
  end
end
