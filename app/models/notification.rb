# == Schema Information
#
# Table name: notifications
#
#  id             :bigint           not null, primary key
#  recipient_type :string           not null
#  recipient_id   :bigint           not null
#  type           :string           not null
#  params         :jsonb
#  read_at        :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Notification < ApplicationRecord
  include Noticed::Model
  include Turbo::Broadcastable
  belongs_to :recipient, polymorphic: true

  scope :with_user, ->(user_id) { where(recipient_id: user_id, recipient_type: "User") }

  def course
    params.dig(:course)
  end

  def user
    return @user if defined?(@user)

    if recipient_type == "User"
      @user = User.find(recipient_id)
    else
      @user = nil
    end
  end

  after_commit do
    if read_at_previously_was.nil? && read_at.present?
      broadcast_remove_to user
    elsif read_at.nil?
      broadcast_append_later_to user,
                                target: "notifications",
                                html: ApplicationController.render(
                                  Notifications::NotificationComponent.new(notification: self), layout: false)
    end
  end

end
