module Courses
  class UpdateQueueStatus
    def initialize(course:, new_status:, by_user:)
      @course = course
      @new_status = new_status
      @by_user = by_user
    end

    def call
      @course.update!(open: new_status)

      RenderComponentJob.perform_later("Courses::QueueOpenStatusComponent",
        @course,
        opts: { target: "queue-open-status" },
        component_args: { course: @course })

      if @course.open_previously_was == false && @course.open == true
        CourseChannel.broadcast_to @course, {
          type: "event",
          event: "course:open",
          payload: {
            course_id: @course.id
          }
        }

      elsif @course.open_previously_was == true && @course.open == false
        CourseChannel.broadcast_to @course, {
          type: "event",
          event: "course:close",
          payload: {
            course_id: @course.id
          }
        }
      end

      RenderComponentJob.perform_later("Courses::OpenButtonComponent",
        @course,
        opts: { target: "open-button" },
        component_args: { course: @course })
      log_queue
    end

    def log_queue
      log = QueueStatusLog.create(course: course, new_status: new_status, number_students: course.active_questions.count)
      log.users << by_user
    end

    private

    attr_accessor :course, :new_status, :by_user
  end
end