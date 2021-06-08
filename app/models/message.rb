class Message < ApplicationRecord
  belongs_to :user
  belongs_to :question_state

  delegate :course, to: :question_state, allow_nil: true

  after_update do
    ActionCable.server.broadcast "react-students", {
      invalidate: ['questions', question_state.question_id, 'messages']
    }

  end
end
