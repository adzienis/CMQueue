class PingJob < ApplicationJob
  queue_as :default

  def perform
    User.all.each do |user|
      if SiteChannel.broadcast_to(user, {
        type: 'ping',
        message: 'ping'
      }).positive?
        User.update(last_pinged_at: Time.current.utc, last_active_at: Time.current.utc)
      end
    end
  end
end
