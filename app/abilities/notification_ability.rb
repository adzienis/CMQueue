class NotificationAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?

    can :manage, Notification, Notification.where(recipient_type: "User", recipient_id: user.id) do |notification|
      notification.recipient_type == "User" && notification.recipient_id == user.id
    end
  end
end
