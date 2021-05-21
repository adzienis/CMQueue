class Question < ApplicationRecord
  validates_presence_of :location, :description, :tried

  belongs_to :course
  belongs_to :user

  has_many :question_states, dependent: :destroy
  has_one :question_state, -> { order('created_at DESC') }, dependent: :destroy

  has_and_belongs_to_many :tags, dependent: :destroy

  scope :questions_by_state, ->(states) { joins(:question_state)
                                            .where('question_states.id = (SELECT MAX(question_states.id)
                                        FROM question_states where question_states.question_id = questions.id)')
                                            .where("question_states.state in (#{states.map { |x| QuestionState.states[x] }.join(',')})")
                                            .order("question_states.created_at DESC")
  }

  scope :previous_questions, ->(question) {
    joins(:question_state)
      .where("questions.created_at < ?", question.created_at)
      .where(user_id: question.user_id)
      .where(course_id: question.course_id)
      .order("questions.created_at DESC")
      .distinct
  }

  after_update do
    ActionCable.server.broadcast "react-students", {
      invalidate: ['courses',
                   course_id,
                   'questions']
    }

    ActionCable.server.broadcast "react-students", {
      invalidate: ['courses', course_id, 'topQuestion']
    }

  end

  after_create do
    ActionCable.server.broadcast "react-students", {
      invalidate: ['courses', course_id, 'paginatedQuestions']
    }

    ActionCable.server.broadcast "react-students", {
      invalidate: ['courses', course_id, 'paginatedPastQuestions']
    }

  end

  after_create_commit do
    update(question_state: QuestionState.create(question_id: id, user_id: user_id))
  end

  after_destroy do
    ActionCable.server.broadcast "react-students", {
      invalidate:
        ['courses', course_id, 'questions']
    }
    ActionCable.server.broadcast "react-students", {
      invalidate: ['courses', course.id, 'questions', '?', "user_id=#{user_id}"]
    }
  end

end
