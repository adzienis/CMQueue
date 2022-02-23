module Courses
  class UpdateQueueStatus
    def initialize(course:, new_status:, by_user:)
      @course = course
      @new_status = new_status
      @by_user = by_user
    end

    def call
      @course.update!(open: new_status)
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