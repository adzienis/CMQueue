class QuestionState < ApplicationRecord
  belongs_to :question, touch: true, optional: true
  belongs_to :user
  enum state: %i[unresolved resolving resolved frozen kicked], _default: :unresolved

  has_many :messages, dependent: :destroy

  delegate :course, to: :question, allow_nil: true

  def self.ransackable_scopes(auth_object = nil)
    %i(previous_questions)
  end

  scope :previous_questions, ->(question = nil) {
    q = Question.find_by_id(question)

    return none unless q

    where(question_id: Question
                         .where("questions.created_at < ?", q.created_at)
                         .where(user_id: q.user_id)
                         .where(course_id: q.course_id)
                         .order("questions.created_at DESC")
                         .pluck("questions.id"))
  }

  after_create_commit do
    question.update(question_state: self)
    self.user.update(question_state: self)

    QueueChannel.broadcast_to course, {
      invalidate: ['courses', question.course.id, 'activeTAs']
    }

    ActionCable.server.broadcast "#{course.id}#ta", {
      invalidate: ['courses', question.course.id, 'topQuestion']
    }

    QueueChannel.broadcast_to course, {
      invalidate: ['courses', course.id, 'questions']
    }

    ActionCable.server.broadcast "#{course.id}#ta", {
      invalidate: ['courses', question.course_id, 'paginatedQuestions']
    }

    ActionCable.server.broadcast "#{course.id}#ta", {
      invalidate: ['courses', question.course_id, 'paginatedPastQuestions']
    }

  end
end
