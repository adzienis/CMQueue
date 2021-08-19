class CleanupCertJob < ApplicationJob
  queue_as :default

  def perform(course_id)
    system "rm -rf ./scripts/course_#{course_id}_user"
  end
end
