class RefreshActiveStaffJob < ApplicationJob
  queue_as :course_queue

  def perform(*args)
    Course.all.each do |course|
      SyncedTurboChannel
        .broadcast_replace_later_to course,
          target: "active-staff",
          html: ApplicationController
            .render(Courses::ActiveStaffComponent.new(course: course),
              layout: false)
    end
  end
end
