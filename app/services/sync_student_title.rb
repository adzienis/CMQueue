class SyncStudentTitle < ApplicationService

  def initialize(enrollment:)
    @enrollment = enrollment
  end

  def call
    msg = question.present? ? (question.position_in_course + 1).ordinalize : "N/A"
    msg = "Resolving" if question.resolving?
    TitleChannel.broadcast_to(question.user, msg)
  end

  private

  attr_accessor :enrollment

  def question
    @question ||= enrollment.active_question
  end
end