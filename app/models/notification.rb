class Notification < ApplicationRecord
  include Noticed::Model
  belongs_to :recipient, polymorphic: true


  scope :with_user, ->(user_id) { where(recipient_id: user_id, recipient_type: "User")}

  after_update do
    Noticed::NotificationChannel.broadcast_to recipient, {
      invalidate: ['users', recipient.id, 'notifications']
    }
  end
end
