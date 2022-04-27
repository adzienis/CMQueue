class UpdateQuestionPosition < ApplicationService

  delegate :course, to: :question
  delegate :questions_on_queue, to: :course

  def initialize(question:)
    @question = question
  end

  def call
    broadcast_to_staff
    broadcast_to_user
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

  def broadcast_to_user
    msg = question.position_in_course.present? ? (question.reload.position_in_course + 1).ordinalize : "N/A"
    msg = "Resolving" if question.resolving?
    TitleChannel.broadcast_to question.user, msg
  end
end