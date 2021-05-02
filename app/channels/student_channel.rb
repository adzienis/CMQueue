class StudentChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'students'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
