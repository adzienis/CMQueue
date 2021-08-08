# frozen_string_literal: true

class Question < ApplicationRecord
  include Discard::Model
  include RansackableConcern
  include ExportableConcern

  belongs_to :enrollment
  has_one :course, through: :enrollment
  has_one :user, through: :enrollment
  # this basically alias question_state
  has_one :question_state, -> { order('created_at DESC') }, class_name: "QuestionState", dependent: :destroy

  has_and_belongs_to_many :tags, dependent: :destroy, autosave: true

  #has_many :notifications, as: :recipient

  has_many :question_states, dependent: :destroy

  validates :location, :description, :tried, :course_id, :tags, presence: true

  validate :duplicate_question, on: :create
  validate :has_at_least_one_tag, on: [:create, :update]
  validate :course_queue_open, on: :create

  ######### Handle at least one tag with '='
  # We have to manually override the assignment since we don't have callbacks
  # that accurately represent the count of the number of tags before we destroy
  # them (using '=').
  attr_accessor :tags_validator
  validate :check_for_tags_validator, on: [:create, :update]

  def check_for_tags_validator
    errors.add(:tags, "at least one") if self.tags_validator
  end

  def course_queue_open
    course = Course.find_by(id: course_id)
    return unless course

    errors.add(:course, "is closed.") if !course.open
  end

  def has_at_least_one_tag
    if tags.length == 0
      errors.add(:tags, "must have at least one.")
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
  scope :with_course, ->(course) { where(course_id: course.id) }

  scope :by_state, lambda { |*states|
    joins(:question_state)
      .where('question_states.id = (SELECT MAX(question_states.id)
                                        FROM question_states where question_states.question_id = questions.id)')
      .where("question_states.state": states)
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

  scope :with_user, ->(user_id) {
    joins(:question_states, :enrollment).where("enrollments.user_id": user_id)
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

  def unfreeze(enrollment_id)
    question_states.create(enrollment_id: enrollment_id, state: "unresolved")
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[previous_questions]
  end

  def tags=(value)
    if value.empty?
      self.tags_validator = true
      self.valid?
    else
      super(value)
    end
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
