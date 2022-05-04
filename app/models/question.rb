# frozen_string_literal: true

# == Schema Information
#
# Table name: questions
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  title         :text
#  tried         :text
#  description   :text
#  notes         :text
#  location      :text
#  discarded_at  :datetime
#  enrollment_id :bigint           not null
#
require "pagy/extras/searchkick"

class Question < ApplicationRecord
  include Discard::Model
  include Exportable
  include GuardableTransactions
  extend Pagy::Searchkick

  searchkick
  has_paper_trail(limit: nil)

  scope :search_import, -> { includes(:question_state, :user, :tags) }

  def search_data
    {
      id: id,
      tried: tried,
      description: description,
      location: location,
      state: question_state&.state,
      discarded_at: discarded_at,
      created_at: created_at,
      user_name: "#{user.given_name} #{user.family_name}",
      resolved_by: question_state&.state == "resolved" ? question_state.user.given_name : nil,
      tags: tags.map(&:name),
      course_id: course.id,
      semester: enrollment.semester
    }
  end

  belongs_to :enrollment, inverse_of: :questions
  has_one :course, through: :enrollment
  has_one :user, through: :enrollment
  # this basically alias question_state
  has_one :question_state, -> { order("max(id) DESC").group("question_states.id") },
    class_name: "QuestionState",
    inverse_of: :question

  has_many :question_tags, dependent: :destroy
  has_many :tags, through: :question_tags, autosave: true, inverse_of: :questions

  # has_many :notifications, as: :recipient

  has_many :tag_groups, through: :tags
  has_many :question_states, dependent: :destroy, inverse_of: :question

  validates :location, :description, :tried, presence: true

  validate :duplicate_question, on: :create
  validate :course_queue_open, on: :create
  # validate :has_at_least_one_tag

  accepts_nested_attributes_for :question_state
  validates_associated :question_state

  def create_question_state(*params)
    guard_db(association: :question_state) do
      qs = question_states.build(*params)
      qs.save!
    end
  end

  def unsafely_create_question_state(*params)
    guard_db(association: :question_state) do
      qs = question_states.build(*params)
      qs.save!(validate: false)
    end
  end

  def total_time_to_resolve
    questions_states.order("min(id) DESC")
  end

  def related_questions(date: created_at)
    Question.where(enrollment: enrollment, created_at: date.all_day).where("id != ?", id)
  end

  def time_to_resolve
    last_unresolved = question_states.order(created_at: :asc).where(state: "unresolved").last
    last_resolved = question_states.order(created_at: :asc).where(state: ["resolved", "kicked"]).last

    if last_resolved.present?
      last_resolved.created_at - last_unresolved.created_at
    else
      Time.now - last_unresolved.created_at
    end
  end

  def course_queue_open
    errors.add(:course, "is closed.") unless course.open
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
  scope :unresolved, -> { by_state("unresolved") }

  scope :by_state, lambda { |*states|
    joins(:question_state)
      .where('question_states.id = (SELECT MAX(question_states.id)
                                        FROM question_states where question_states.question_id = questions.id)')
      .where("question_states.state": states)
  }

  scope :by_state_with_user, lambda { |user, *states|
    where(id:
            QuestionState.where(id:
                                  QuestionState
                                    .select("max(question_states.id) as max")
                                    .group(:question_id))
                         .where(state: states)
                         .joins(:user)
                         .where(users: user)
                         .pluck(:question_id))
  }

  scope :previous_questions, lambda { |question = nil|
    q = Question.find_by(id: question)
    return Question.none unless q

    joins(:enrollment)
      .where("questions.created_at < ?", q.created_at)
      .where("enrollments.user_id": q.enrollment.user_id)
      .where(course: course)
  }

  scope :with_today, -> {
    where(created_at: DateTime.current.all_day)
  }

  scope :with_users, ->(*users) {
    joins(:enrollment).where("enrollments.user": users)
  }

  def position_in_course
    course.questions.undiscarded.order(created_at: :asc).by_state("unresolved").pluck(:id).index(id)
  end

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
    resolving(enrollment_id: enrollment_id)
  end

  def resolve(enrollment_id)
    transition_to_state("resolved", enrollment_id)
  end

  def transition_to_state(state, enrollment_id = send(:enrollment_id), description: nil)
    return false if errors.any?

    guard_db do
      Postgres::Locks.pg_advisory_xact_lock(id)
      question_states.create!(enrollment_id: enrollment_id, state: state, description: description)
    end
  end

  def resolving(enrollment_id: self.enrollment_id)
    transition_to_state("resolving", enrollment_id)
  end

  def kick(enrollment_id: self.enrollment_id)
    transition_to_state("kicked", enrollment_id)
  end

  def freeze_question(enrollment_id: self.enrollment_id)
    transition_to_state("frozen", enrollment_id)
  end

  def unfreeze(enrollment_id: self.enrollment_id)
    transition_to_state("unresolved", enrollment_id)
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[previous_questions]
  end

  def just_added_to_queue?
    question_states.count == 1 && question_state.unresolved?
  end

  after_discard do
    comp = Forms::Questions::QuestionCreatorComponent.new(course: course,
      question_form: Forms::Question.new(question: Question.new),
      current_user: user)

    SyncedTurboChannel.broadcast_replace_later_to user,
      target: "question-form",
      html: ApplicationController.render(comp, layout: false)

    count = course.questions_on_queue.count
    TitleChannel.broadcast_to_staff course: course, message: count == 1 ? "#{count} question" : "#{count} questions"
    SyncedTurboChannel.broadcast_replace_later_to course,
      target: "questions-count",
      html: ApplicationController.render(Courses::QuestionsCountComponent.new(course: course),
        layout: false)

    Courses::UpdatePositionsJob.perform_later(course: course)
    component = Courses::QuestionPositionComponent.new(question: self)
    SyncedTurboChannel.broadcast_replace_later_to user,
      target: "question-position",
      html: ApplicationController.render(component, layout: false)
    TitleChannel.broadcast_to user, position_in_course&.ordinalize
  end

  after_commit on: :create do
    update!(question_state: QuestionState.create!(question_id: id, enrollment_id: enrollment_id))
    if course.active_questions.count == 1
      course.staff.each do |member|
        SiteNotification.with(message: "New question on the queue").deliver_later(member.user)
      end
    end

    Courses::UpdateFeedJob.perform_later(course: course)
  end

  after_commit on: :update do
    RenderComponentJob.perform_later("Courses::Feed::QuestionCardComponent",
                                     self,
                                     opts: { target: self  },
                                     component_args: {question: self})

    Courses::UpdateFeedJob.perform_later(course: course)
  end

  after_commit do
    reindex(refresh: true)
  end

  singleton_class.send(:alias_attribute, :current_state, :question_state)

  singleton_class.send(:alias_method, :questions_by_state, :by_state)
end
