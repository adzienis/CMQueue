class Courses::UpdatePositionsJob < ApplicationJob
  queue_as :course_queue

  def perform(course:)
    course.questions.undiscarded.by_state("unresolved").includes(:user)
      .order(created_at: :asc)
      .each_with_index.each do |question, i|
      component = Courses::QuestionPositionComponent.new(question: question, position: i)
      SyncedTurboChannel.broadcast_replace_later_to question.user,
        target: "question-position",
        html: ApplicationController.render(component, layout: false)
      TitleChannel.broadcast_to question.user, (i + 1).ordinalize
    end
  end
end
