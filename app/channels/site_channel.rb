class SiteChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    current_user.update(last_active_at: Time.current.utc)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
