class Notification < ApplicationRecord
  include Noticed::Model
  belongs_to :recipient, polymorphic: true


  after_update do
    Noticed::NotificationChannel.broadcast_to recipient, {
      invalidate: ['users', recipient.id, 'unread_notifications']
    }
  end
end
