module Courses
  class BroadcastQuestionsOnQueue
    include ApplicationService

    def initialize(course:, staff:)
      @course = course
      @staff  = staff
    end

    def call
      TitleChannel.broadcast_to_staff course: course, message: count == 1 ? "#{count} question" : "#{count} questions"
    end

    private

    attr_accessor :course, :staff

  end
end