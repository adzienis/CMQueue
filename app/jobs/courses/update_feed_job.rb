class Courses::UpdateFeedJob < ApplicationJob
  queue_as :course_queue

  def perform(course:)
  end
end
