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
      question_creator: "#{question.user.given_name} #{question.user.family_name}",
      course_id: course.id
    }
  end

  include Turbo::Broadcastable

  belongs_to :question, inverse_of: :question_states, optional: false, touch: true
  belongs_to :enrollment
  has_one :user, through: :enrollment

  validates_presence_of :question, :enrollment
  validate :not_handling_another, on: :create
  validate :valid_transition, on: :create

  def as_json(options = {})
    super(options.merge({
      include: [:user]
    }))
  end

  def valid_transition
    old_qs = question.reload.question_state&.state

    return unless old_qs

    valid_next_states = case old_qs
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

    unless valid_next_states.include?(state)
      if old_qs == "resolving" && resolving?
        errors.add(:base, "Another staff member just answered this question.")
      else
        errors.add(:base, "invalid action (can't transition #{old_qs} -> #{state})")
      end
    end
  end

  def not_handling_another
    return unless user&.question_state && question
    errors.add(:user, "is already handling another question") if user.question_state.resolving? && question.id != user.question_state.question.id
  end

  enum state: {unresolved: 0, resolving: 1, resolved: 2, frozen: 3, kicked: 4}, _default: :unresolved

  scope :with_courses, ->(course) { joins(enrollment: {role: :course}).where("courses.id": course.id) }
  scope :with_user, ->(user_id) { joins(:enrollment).where("enrollments.user_id": user_id) }

  # has_many :messages, dependent: :destroy

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
                         .where("questions.created_at < ?", q.created_at)
                         .where(user_id: q.user_id)
                         .where(course_id: q.course_id)
                         .order("questions.created_at DESC")
                         .pluck("questions.id"))
  }

  after_commit do
    question.reload.reindex(refresh: true)

    count = course.questions_on_queue.count
    TitleChannel.broadcast_to_staff course: course, message: count == 1 ? "#{count} question" : "#{count} questions"
    TitleChannel.broadcast_to question.user,
      question.position_in_course.present? ? (question.reload.position_in_course + 1).ordinalize : "N/A"

    RenderComponentJob.perform_later("Courses::QuestionPositionComponent",
      question.user,
      opts: {target: "question-position"},
      component_args: {question: question})

    if resolving?
      SiteNotification.with(message: "Your question is currently being resolved.").deliver_later(question.user)
    end

    if false

      if resolved?
        RenderComponentJob.perform_later("Forms::Questions::QuestionCreatorComponent",
          question.user,
          opts: {target: "form"},
          component_args: {course: course,
                           question: nil,
                           current_user: question.user})
      else
        RenderComponentJob.perform_later("Forms::Questions::QuestionCreatorComponent",
          question.user,
          opts: {target: "form"},
          component_args: {course: course,
                           question: question,
                           current_user: question.user})
      end
    end

    RenderComponentJob.perform_later("Courses::QuestionsCountComponent",
      course,
      opts: {target: "questions-count"},
      component_args: {course: course})

    RenderComponentJob.perform_later("Courses::ActiveStaffComponent",
      course,
      opts: {target: "active-staff"},
      component_args: {course: course})

    Courses::UpdatePositionsJob.perform_later(course: course)
  end
end
