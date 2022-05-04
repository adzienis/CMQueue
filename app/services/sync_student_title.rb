class SyncStudentTitle < ApplicationService

  def initialize(enrollment:)
    @enrollment = enrollment
  end

  def call
    return TitleChannel.broadcast_to(enrollment.user, "N/A") unless question.present?

    msg = (question.position_in_course + 1).ordinalize if question.position_in_course.present?
    msg = "Resolving" if question.resolving?
    TitleChannel.broadcast_to(enrollment.user, msg)
  end

  private

  attr_accessor :enrollment

  def question
    @question ||= enrollment.active_question
  end
end