# frozen_string_literal: true

class ReactStudentChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'react-students'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
