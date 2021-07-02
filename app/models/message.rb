# frozen_string_literal: true

class Message < ApplicationRecord
  #belongs_to :user
  #belongs_to :question_state

  delegate :course, to: :question_state, allow_nil: true

  scope :with_course, lambda { |course|
                        joins(:question_state).joins(question_state: :question).where("questions.course_id": course.id)
                      }

  after_create do
    ActionCable.server.broadcast "#{course.id}#ta", {
      invalidate: ['questions', question_state.question_id, 'messages']
    }

    ActionCable.server.broadcast "#{course.id}#instructor", {
      invalidate: ['questions', question_state.question_id, 'messages']
    }

    QueueChannel.broadcast_to question_state.question.user, {
      invalidate: ['questions', question_state.question_id, 'messages']
    }
  end

  after_update do
    ActionCable.server.broadcast "#{course.id}#ta", {
      invalidate: ['questions', question_state.question_id, 'messages']
    }

    ActionCable.server.broadcast "#{course.id}#instructor", {
      invalidate: ['questions', question_state.question_id, 'messages']
    }

    QueueChannel.broadcast_to question_state.question.user, {
      invalidate: ['questions', question_state.question_id, 'messages']
    }
  end
end
