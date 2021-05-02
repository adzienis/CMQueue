class QuestionState < ApplicationRecord
  belongs_to :question, touch: true, optional: true
  belongs_to :user
  enum state: %i[unresolved resolving resolved frozen kicked], _default: :unresolved

  has_many :messages, dependent: :destroy

  after_create_commit do
    question.update(question_state: self)
    self.user.update(question_state: self)



    ActionCable.server.broadcast "react-students", {
      invalidate: ['courses', question.course.id, 'activeTAs']
    }

    ActionCable.server.broadcast "react-students", {
      invalidate: ['courses', question.course.id, 'topQuestion']
    }

    ActionCable.server.broadcast "react-students", {
      invalidate: ['courses', question.course_id, 'paginatedQuestions']
    }

    ActionCable.server.broadcast "react-students", {
      invalidate: ['courses', question.course_id, 'paginatedPastQuestions']
    }

  end
end
