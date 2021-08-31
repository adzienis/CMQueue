# frozen_string_literal: true

class User < ApplicationRecord
  has_many :enrollments, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy

  alias_attribute :current_state, :question_state
  attr_accessor :question_state

  #has_many :access_grants,
  #         class_name: 'Doorkeeper::AccessGrant',
  #         foreign_key: :resource_owner_id,
  #         dependent: :delete_all
  #has_many :access_tokens,
  #         class_name: 'Doorkeeper::AccessToken',
  #         foreign_key: :resource_owner_id,
  #         dependent: :delete_all

  has_many :active_questions, -> { undiscarded.questions_by_state("unresolved", "frozen", "resolving").or(undiscarded.by_state("kicked").unacknowledged) }, through: :enrollments, source: :questions

  has_many :courses, through: :enrollments

  has_many :questions, dependent: :destroy, through: :enrollments

  has_many :question_states, -> { order('question_states.id DESC') }, through: :enrollments, dependent: :destroy, source: :question_states

  has_many :settings, as: :resource, dependent: :destroy

  # add scopes for course
  has_many :applications, class_name: "Doorkeeper::Application", as: :owner

  #has_many :oauth_applications, as: :owner

  def enrolled_in_course?(course_id)
    enrollments.undiscarded.joins(:role).where("roles.resource_id": course_id, "roles.resource_type": "Course").any?
  end

  def unacknowledged_kicked_question?
    !unacknowledged_kicked_question.nil?
  end

  def unacknowledged_kicked_question
    questions.by_state("kicked").unacknowledged.first
  end

  def active_question?
    !active_question.nil?
  end

  def active_question
    active_questions.first
  end

  def is_staff_in_course?(course_id)
    course = Course.find(course_id)
    has_any_role?({ name: :ta, resource: course }, { name: :instructor, resource: course })
  end

  def enrollment_with_course(course_id)
    enrollments.undiscarded.joins(:role).find_by("roles.resource_type": "Course", "roles.resource_id": course_id)
  end

  def question_state
    question_states.order('question_states.id DESC').first
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[with_role_ransack]
  end

  scope :with_course, ->(course_id) { joins(:enrollments, enrollments: :role).where("roles.resource_id": course_id, "roles.resource_type": "Course") }

  scope :undiscarded_enrollments, -> { joins(:enrollments).merge(Enrollment.undiscarded) }

  scope :enrolled_in_course, lambda { |course|
    joins(:roles).where("roles.resource_id": course.id)
  }

  scope :resolved_questions, lambda {
    joins(:question_states)
      .where("question_states.state": 'resolved')
  }

  scope :with_role_ransack, lambda { |role|
    if role.to_s == 'any'
      joins(:roles).distinct
    else
      joins(:roles).where("roles.name": role.to_s).distinct
    end
  }

  scope :with_any_roles, lambda { |*names|
    where(id: joins(:roles).where('roles.name IN (?)', names).merge(Role.undiscarded))
  }

  scope :active_tas_by_date, lambda { |states, date, course|
    joins(:question_state)
      .where("question_states.state in (#{states.map do |x|
        QuestionState.states[x]
      end.join(',')})")
      .where('question_states.created_at >= ?', date.beginning_of_day)
      .where('question_states.created_at <= ?', date.end_of_day)
      .with_role(:ta, course)
      .distinct('users.id')
  }

  def full_name
    "#{given_name} #{family_name}"
  end

  def self.from_omniauth(auth)
    find_or_create_by(email: auth.extra&.id_info.email) do |user|
      user.given_name = auth.extra.id_info.given_name
      user.family_name = auth.extra.id_info.family_name
      user.email = auth.extra.id_info.email
    end
  end

  def self.from_hash(auth)
    find_or_create_by(email: auth[:email]) do |user|
      user.given_name = auth["given_name"]
      user.family_name = auth["family_name"]
      user.email = auth["email"]
    end
  end

  def self.to_csv
    attributes = %w{id given_name family_name}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.find_each do |user|
        csv << attributes.map { |attr| user.send(attr) }
      end
    end
  end

  after_create_commit do
    settings.create([{
                       value: {
                         desktop_notifications: {
                           label: "Desktop Notifications",
                           value: false,
                           description: "Allow notifications to appear natively on your desktop.",
                           type: "boolean"
                         }
                       }
                     }, {
                       value: {
                         site_notifications: {
                           label: "Site Notifications",
                           value: false,
                           description: "Allow notifications to appear on the site.",
                           type: "boolean"
                         }
                       }
                     }])
  end

  rolify has_many_through: :enrollments
  devise :omniauthable, omniauth_providers: %i[google_oauth2]
end
