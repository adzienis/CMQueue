# frozen_string_literal: true

require './lib/postgres/views/course'
require './lib/postgres/views/question'
require './lib/postgres/views/tag'
require './lib/postgres/views/enrollment'
require './lib/postgres/views'

class Course < ApplicationRecord
  resourcify

  validates :name, uniqueness: true
  validates :ta_code, presence: true, uniqueness: true
  validates :student_code, presence: true, uniqueness: true
  validates :instructor_code, presence: true, uniqueness: true

  # Not required for now
  # validates :course_code, presence: true, uniqueness: true

  has_many :enrollments, through: :roles
  has_many :users, through: :enrollments
  has_many :questions
  has_many :unresolved_questions, -> { undiscarded
                                         .questions_by_state("unresolved") }, class_name: "Question"
  has_many :active_questions, -> { undiscarded
                                     .questions_by_state("unresolved", "frozen", "resolving")
                                     .or(undiscarded.by_state("kicked").unacknowledged) }, class_name: "Question"
  has_many :tags
  #has_many :announcements

  has_many :access_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :delete_all

  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :delete_all

  has_many :applications, class_name: "Doorkeeper::Application", as: :owner

  before_validation on: :create do
    self.ta_code = SecureRandom.urlsafe_base64(6) unless ta_code
    self.student_code = SecureRandom.urlsafe_base64(6) unless student_code
    self.instructor_code = SecureRandom.urlsafe_base64(6) unless instructor_code
  end

  def available_tags
    tags.undiscarded.unarchived.distinct
  end

  after_update do
    broadcast_action_later_to self,
                              action: :refresh,
                              target: "question-creator-container",
                              template: nil

    QueueChannel.broadcast_to self, {
      invalidate: ['courses', id, 'open_status']
    }
  end

  after_create_commit do
    Postgres::Views::Course.create(id)
    Postgres::Views::Question.create(id)
    Postgres::Views::Tag.create(id)
    Postgres::Views::Enrollment.create(id)
  end

  after_destroy_commit do
    Postgres::Views::Course.destroy(id)
    Postgres::Views::Question.destroy(id)
    Postgres::Views::Tag.destroy(id)
    Postgres::Views::Enrollment.destroy(id)

    Postgres::Views.destroy_user(id)
  end
end
