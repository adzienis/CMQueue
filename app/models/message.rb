class Message < ApplicationRecord
  belongs_to :user
  belongs_to :question_state

  after_update do


    ActionCable.server.broadcast "react-students", {
      invalidate: ['questions', question_state.question_id, 'messages']
    }

  end
end
