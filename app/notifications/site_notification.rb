# To deliver this notification:
#
# SiteNotification.with(post: @post).deliver_later(current_user)
# SiteNotification.with(post: @post).deliver(current_user)

class SiteNotification < Noticed::Base
  # Add your delivery methods
  #
  deliver_by :database
  deliver_by :action_cable, format: :to_action_cable

  def to_action_cable
    {
      type: self.class.name,
      params: params,
      invalidate: ['users', recipient.id, 'notifications']
    }
  end

  def self.success(target, message, delay=nil)
    if delay
      SiteNotification.with(type: "Success", body: message, title: "Success", delay: delay).deliver_later(target)
    else
      SiteNotification.with(type: "Success", body: message, title: "Success").deliver_later(target)
    end
  end

  def self.student_on_queue(target, delay=nil)
    if delay
      SiteNotification.with(type: "Success", body: message, title: "Success", delay: delay).deliver_later(target)
    else
      SiteNotification.with(type: "Success", body: message, title: "Success").deliver_later(target)
    end
  end

  def self.failure(target, message, delay=nil)
    if delay
      SiteNotification.with(type: "Failure", body: message, title: "Failure", delay: delay).deliver_later(target)
    else
      SiteNotification.with(type: "Failure", body: message, title: "Failure").deliver_later(target)
    end
  end

  after_deliver do
    if params.key? :delay
      ClearNotificationJob.set(wait: params[:delay].seconds).perform_later(record.id)
    end
  end

  # deliver_by :email, mailer: "UserMailer"
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  # param :post

  # Define helper methods to make rendering easier.
  #
  # def message
  #   t(".message")
  # end
  #
  # def url
  #   post_path(params[:post])
  # end
end
