class CleanupCertJob < ApplicationJob
  queue_as :default

  def perform(course_id)
    #system "rm -rf ./ssl/course_#{course_id}_user"
  end
end
