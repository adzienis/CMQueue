# frozen_string_literal: true

# == Schema Information
#
# Table name: question_states
#
#  id              :bigint           not null, primary key
#  question_id     :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  description     :text
#  state           :integer          not null
#  enrollment_id   :bigint           not null
#  acknowledged_at :datetime
#
class QuestionState < ApplicationRecord
  searchkick

  scope :search_import, -> { includes(:question, :enrollment, :user) }

  def search_data
    {
      id: id,
      state: state,
      discarded_at: question.discarded_at,
      state_creator: "#{user.given_name} #{user.family_name}",
      question_creator: "#{question.user.given_name} #{question.user.family_name}"
    }
  end

  include Ransackable
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

  scope :with_courses, ->(course) { joins(enrollment: { role: :course }).where("courses.id": course.id) }
  scope :with_user, ->(user_id) { joins(:enrollment).where("enrollments.user_id": user_id) }

  #has_many :messages, dependent: :destroy

  has_one :course, through: :question

  def self.ransackable_scopes(_auth_object = nil)
    %i[previous_questions]
  end

  def last_active_question(course: nil)
    joins(question: :enrollment).merge(Enrollment.with_courses(course)).order(created_at: :desc).first
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

  after_commit do
    question.reload.reindex

    comp = Forms::Question::QuestionCreatorComponent.new(course: course,
                                                         question_form: Forms::Question.new(question: question),
                                                         current_user: question.user
    )

    broadcast_replace_later_to question.user,
                              target: "question-form",
                              html: ApplicationController.render(comp, layout: false),
                              channel: SyncedTurboChannel

    broadcast_replace_later_to course,
                        target: "questions-count",
                        html: ApplicationController.render(Courses::QuestionsCountComponent.new(course: course),
                                                           layout: false),
                        channel: SyncedTurboChannel

    course.active_questions.each do |question|
      broadcast_replace_later_to question.user,
                          target: "question-position",
                          html: ApplicationController
                                  .render(Courses::QuestionPositionComponent.new(question: question), layout: false),
                          channel: SyncedTurboChannel
    end

    QueueChannel.broadcast_to course, {
      type: "event",
      event: "invalidate:question-feed"
    }
  end
end
