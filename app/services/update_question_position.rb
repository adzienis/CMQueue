class UpdateQuestionPosition < ApplicationService

  delegate :course, to: :question
  delegate :questions_on_queue, to: :course

  def initialize(question:)
    @question = question
  end

  def call
    broadcast_to_staff
    course.active_questions.includes(:enrollment).each do |question|
      SyncStudentTitle.call(enrollment: question.enrollment)
    end
  end

  private

  attr_accessor :question

  def questions_count
    @questions_count ||= questions_on_queue.count
  end

  def broadcast_to_staff
    msg = questions_count == 1 ? "#{questions_count} question" : "#{questions_count} questions"
    TitleChannel.broadcast_to_staff(course: course, message: msg)
  end
end