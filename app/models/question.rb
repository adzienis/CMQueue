# frozen_string_literal: true

class Question < ApplicationRecord
  include Discard::Model

  validates :location, :description, :tried, presence: true
  validate :duplicate_question, :on => :create

  def duplicate_question
    state = QuestionState.find_by(id: QuestionState.joins(:question).where("questions.user_id": user_id).where("questions.discarded_at is null").select("MAX(question_states.id)").pluck(:id))

    return unless state

    if state.state == "resolving" || state.state == "unresolved" || state.state == "frozen"
      errors.add(:question, "already exists")
    end
  end

  belongs_to :course
  belongs_to :user

  has_many :question_states, dependent: :destroy
  has_one :question_state, -> { order('created_at DESC') }, dependent: :destroy

  has_and_belongs_to_many :tags, dependent: :destroy

  def self.ransackable_scopes(_auth_object = nil)
    %i[previous_questions]
  end

  scope :with_course, ->(course) { where(course_id: course.id) }

  scope :questions_by_state, lambda { |states|
    joins(:question_state)
      .where('question_states.id = (SELECT MAX(question_states.id)
                                        FROM question_states where question_states.question_id = questions.id)')
      .where("question_states.state in (#{states.map do |x|
        QuestionState.states[x]
      end.join(',')})")
      .order('question_states.created_at DESC')
  }

  scope :previous_questions, lambda { |question = nil|
    q = Question.find_by(id: question)
    return none unless q

    joins(:question_state)
      .where('questions.created_at < ?', q.created_at)
      .where(user_id: q.user_id)
      .where(course_id: q.course_id)
      .order('questions.created_at DESC')
      .distinct
  }

  after_update do
    QueueChannel.broadcast_to user, {
      invalidate: ['courses',
                   course_id,
                   'questions']
    }

    ActionCable.server.broadcast "#{course.id}#ta", {
      invalidate: ['courses',
                   course_id,
                   'questions']
    }

    ActionCable.server.broadcast "#{course.id}#instructor", {
      invalidate: ['courses',
                   course_id,
                   'questions']
    }


    ActionCable.server.broadcast "#{course.id}#ta", {
      invalidate: ['courses', course_id, 'topQuestion']
    }


    ActionCable.server.broadcast "#{course.id}#instructor", {
      invalidate: ['courses', course_id, 'topQuestion']
    }


    ActionCable.server.broadcast "#{course.id}#ta", {
      invalidate: ['courses', course_id, 'paginatedQuestions']
    }
    ActionCable.server.broadcast "#{course.id}#instructor", {
      invalidate: ['courses', course_id, 'paginatedQuestions']
    }


    ActionCable.server.broadcast "#{course.id}#ta", {
      invalidate: ['courses', course_id, 'paginatedPastQuestions']
    }
    ActionCable.server.broadcast "#{course.id}#instructor", {
      invalidate: ['courses', course_id, 'paginatedPastQuestions']
    }
  end

  after_create do
    ActionCable.server.broadcast "#{course.id}#ta", {
      invalidate: ['courses', course_id, 'paginatedQuestions']
    }
    ActionCable.server.broadcast "#{course.id}#instructor", {
      invalidate: ['courses', course_id, 'paginatedQuestions']
    }


    ActionCable.server.broadcast "#{course.id}#ta", {
      invalidate: ['courses', course_id, 'paginatedPastQuestions']
    }
    ActionCable.server.broadcast "#{course.id}#instructor", {
      invalidate: ['courses', course_id, 'paginatedPastQuestions']
    }
  end

  after_create_commit do
    update(question_state: QuestionState.create(question_id: id, user_id: user_id)) if self
  end

  after_destroy do
    ActionCable.server.broadcast "#{course.id}#ta", {
      invalidate:
        ['courses', course_id, 'questions']
    }
    ActionCable.server.broadcast "#{course.id}#instructor", {
      invalidate:
        ['courses', course_id, 'questions']
    }

    QueueChannel.broadcast_to user, {
      invalidate: ['courses',
                   course_id,
                   'questions']
    }
  end

  after_discard do
    ActionCable.server.broadcast "#{course.id}#ta", {
      invalidate:
        ['courses', course_id, 'questions']
    }
    ActionCable.server.broadcast "#{course.id}#instructor", {
      invalidate:
        ['courses', course_id, 'questions']
    }

    QueueChannel.broadcast_to user, {
      invalidate: ['courses',
                   course_id,
                   'questions']
    }
  end


  def self.to_csv(results)
    attributes = %w{id user_id course_id created_at updated_at tried description location}

    case results
    when Array
      CSV.generate(headers: true) do |csv|
        csv << attributes

        results.each do |user|
          csv << attributes.map { |attr| user.send(attr) }
        end
      end
    when self
      CSV.generate(headers: true) do |csv|
        csv << attributes

        self.each do |user|
          csv << attributes.map { |attr| user.send(attr) }
        end
      end
    else
      puts "failed"
    end
  end
end
