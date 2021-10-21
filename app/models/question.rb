# frozen_string_literal: true

class Question < ApplicationRecord
  include Discard::Model
  include Ransackable
  include Exportable
  include GuardableTransactions

  belongs_to :enrollment
  has_one :course, through: :enrollment
  has_one :user, through: :enrollment
  # this basically alias question_state
  has_one :question_state, -> { order('max(id) DESC').group("question_states.id") }, class_name: "QuestionState", dependent: :destroy

  has_and_belongs_to_many :tags, dependent: :destroy, autosave: true, inverse_of: :questions

  #has_many :notifications, as: :recipient

  has_many :tag_groups, through: :tags
  has_many :question_states, dependent: :destroy

  validates :location, :description, :tried, presence: true

  validate :duplicate_question, on: :create
  validate :course_queue_open, on: :create
  validate :has_at_least_one_tag
  ######### Handle at least one tag with '='
  # We have to manually override the assignment since we don't have callbacks
  # that accurately represent the count of the number of tags before we destroy
  # them (using '=').
  attr_accessor :tags_validator

  def course_queue_open
    course = Course.find_by(id: course_id)
    return unless course

    errors.add(:course, "is closed.") if !course.open
  end

  def has_at_least_one_tag
    if tags.length == 0
      errors.add(:tags, "can't be empty")
    end
  end

  def duplicate_question
    return unless question_state

    if question_state.state == "resolving" ||
      question_state.state == "unresolved" ||
      question_state.state == "frozen"
      errors.add(:question, "already exists.")
    end
  end

  scope :acknowledged, -> { where(id: joins(:question_states).where.not("question_states.acknowledged_at": nil)) }
  scope :unacknowledged, -> { where(id: joins(:question_states).where("question_states.acknowledged_at": nil)) }
  scope :with_courses, ->(*courses) { joins(enrollment: :role).merge(Role.with_courses(courses)) }
  scope :with_courses, ->(*courses) { joins(enrollment: :role).merge(Role.with_courses(courses)) }

  scope :by_state, lambda { |*states|
    joins(:question_state)
      .where('question_states.id = (SELECT MAX(question_states.id)
                                        FROM question_states where question_states.question_id = questions.id)')
      .where("question_states.state": states)
  }

  scope :latest_by_state, lambda { |*states|
    where(id:
            QuestionState.where(id:
                                  QuestionState
                                    .select('max(id) as max')
                                    .group(:question_id))
                         .where(state: states)
                         .pluck(:question_id)
    )

  }

  scope :latest_by_state_with_user, lambda { |user, *states|
    where(id:
            QuestionState.where(id:
                                  QuestionState
                                    .joins(:user)
                                    .where(users: user)
                                    .select('max(question_states.id) as max')
                                    .group(:question_id))
                         .where(state: states)
                         .pluck(:question_id)
    )

  }

  scope :previous_questions, lambda { |question = nil|
    q = Question.find_by(id: question)
    return Question.none unless q

    joins(:enrollment)
      .where('questions.created_at < ?', q.created_at)
      .where("enrollments.user_id": q.enrollment.user_id)
      .where(course_id: q.course_id)
  }

  scope :with_today, -> {
    where(created_at: Date.today.all_day)
  }

  scope :with_users, ->(*users) {
    joins(:enrollment).where("enrollments.user": users)
  }

  def resolved?
    question_state&.state == "resolved"
  end

  def frozen?
    question_state&.state == "frozen"
  end

  def unresolved?
    question_state&.state == "unresolved"
  end

  def resolving?
    question_state&.state == "resolving"
  end

  def kicked?
    question_state&.state == "kicked"
  end

  def unresolve(enrollment_id)
    transition_to_state("unresolved", enrollment_id)
  end

  def answer(enrollment_id)
    resolving(enrollment_id)
  end

  def resolve(enrollment_id)
    transition_to_state("resolved", enrollment_id)
  end

  def transition_to_state(state, enrollment_id=send(:enrollment_id), description: nil)
    return false if errors.any?

    guard_db do
      question_states.create!(enrollment_id: enrollment_id, state: state, description: description)
    end
  end

  def resolving(enrollment_id)
    transition_to_state("resolving", enrollment_id)
  end

  def kick(enrollment_id)
    transition_to_state("kicked", enrollment_id)
  end

  def freeze_question(enrollment_id)
    transition_to_state("frozen", enrollment_id)
  end

  def unfreeze(enrollment_id)
    transition_to_state("unresolved", enrollment_id)
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[previous_questions]
  end

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

    QueueChannel.broadcast_to user, {
      invalidate: ['courses',
                   course_id,
                   'current_question']
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

  after_create_commit do
    update!(question_state: QuestionState.create!(question_id: id, enrollment_id: enrollment_id)) if self
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
    QueueChannel.broadcast_to user, {
      invalidate: ['courses',
                   course_id,
                   'current_question']
    }

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

  singleton_class.send(:alias_attribute, :current_state, :question_state)

  singleton_class.send(:alias_method, :questions_by_state, :by_state)
end
