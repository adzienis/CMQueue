# frozen_string_literal: true

class RefreshActiveTasJob < ApplicationJob
  queue_as :default

  def perform
    Course.all.each do |course|
      QueueChannel.broadcast_to course, {
        invalidate: ['courses', course.id, 'activeTAs']
      }
    end
  end

  after_perform do |_job|
    RefreshActiveTasJob.set(wait: 10.minutes).perform_later
  end
end
