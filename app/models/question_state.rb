# frozen_string_literal: true

class QuestionState < ApplicationRecord
  include RansackableConcern
  include Turbo::Broadcastable
  belongs_to :question, touch: true, optional: false
  belongs_to :enrollment

  has_one :user, through: :enrollment

  validates_presence_of :question, :enrollment
  validate :proper_answer, on: :create
  validate :not_handling_another, on: :create
  validate :valid_transition, on: :create

  def as_json(options = {})
    super(options.merge({
                          include: [:user]
                        }))
  end

  def valid_transition
    old_qs = question.question_state

    return unless old_qs

    valid_next_states = case old_qs.state
                        when "unresolved"
                          ["resolving", "frozen", "kicked"]
                        when "resolving"
                          ["resolved", "unresolved", "frozen", "kicked"]
                        when "resolved"
                          []
                        when "frozen"
                          ["unresolved"]
                        else
                          []
                        end

    errors.add(:state, "invalid action") unless valid_next_states.include? state
  end

  def proper_answer
    return unless question

    old_qs = question.question_state

    return unless old_qs

    errors.add(:question, "already answered") if (old_qs.state != "unresolved") && state == "resolving"
    errors.add(:action, "already occurred") if old_qs.state == state
  end

  def not_handling_another
    return unless user&.question_state && question
    errors.add(:user, "already handling another question") if user.question_state.state == "resolving" && question.id != user.question_state.question.id
  end

  enum state: { unresolved: 0, resolving: 1, resolved: 2, frozen: 3, kicked: 4 }, _default: :unresolved

  scope :with_course, ->(course_id) { joins(:question).where("questions.course_id": course_id) }
  scope :with_user, ->(user_id) { joins(:enrollment).where("enrollments.user_id": user_id) }

  #has_many :messages, dependent: :destroy

  has_one :course, through: :question

  def self.ransackable_scopes(_auth_object = nil)
    %i[previous_questions]
  end

  scope :previous_questions, lambda { |question = nil|
    q = Question.find_by(id: question)

    return none unless q

    where(question_id: Question
                         .where('questions.created_at < ?', q.created_at)
                         .where(user_id: q.user_id)
                         .where(course_id: q.course_id)
                         .order('questions.created_at DESC')
                         .pluck('questions.id'))
  }

  after_create_commit do

    broadcast_action_later_to question.user,
                              action: :refresh,
                              target: "course-active-questions-count",
                              partial: "shared/reload_turbo"

    broadcast_action_later_to question.user,
                              action: :refresh,
                              target: "question-creator-container",
                              partial: "shared/reload_turbo"

    QueueChannel.broadcast_to course, {
      invalidate: ['courses', question.course.id, 'activeTAs']
    }

    ActionCable.server.broadcast "#{course.id}#ta", {
      invalidate: ['api', 'courses', question.course.id, 'topQuestion']
    }

    ActionCable.server.broadcast "#{course.id}#instructor", {
      invalidate: ['api', 'courses', question.course.id, 'topQuestion']
    }

    QueueChannel.broadcast_to course, {
      invalidate: ['courses', course.id, 'questions']
    }

    ActionCable.server.broadcast "#{course.id}#ta", {
      invalidate: ['courses', question.course_id, 'paginatedQuestions']
    }

    ActionCable.server.broadcast "#{course.id}#instructor", {
      invalidate: ['courses', question.course_id, 'paginatedQuestions']
    }

    ActionCable.server.broadcast "#{course.id}#ta", {
      invalidate: ['courses', question.course_id, 'paginatedPastQuestions']
    }

    ActionCable.server.broadcast "#{course.id}#instructor", {
      invalidate: ['courses', question.course_id, 'paginatedPastQuestions']
    }

    ActionCable.server.broadcast "#{course.id}#ta", {
      invalidate: ["courses", question.course_id, "tags", "count"]
    }
    ActionCable.server.broadcast "#{course.id}#instructor", {
      invalidate: ["courses", question.course_id, "tags", "count"]
    }

    case state
    when "frozen"
      # SiteNotification.with(type: "QuestionState", why: description, title: "Question Frozen").deliver(question.enrollment.user)
    when "kicked"
      SiteNotification.with(type: "QuestionState", why: description, title: "Question Kicked").deliver(question.enrollment.user)
    end

  end
end
