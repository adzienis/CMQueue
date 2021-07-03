# frozen_string_literal: true

class User < ApplicationRecord
  has_many :enrollments, dependent: :destroy

  has_many :notifications, as: :recipient, dependent: :destroy

  #has_many :access_grants,
  #         class_name: 'Doorkeeper::AccessGrant',
  #         foreign_key: :resource_owner_id,
  #         dependent: :delete_all
  #has_many :access_tokens,
  #         class_name: 'Doorkeeper::AccessToken',
  #         foreign_key: :resource_owner_id,
  #         dependent: :delete_all

  has_many :courses, through: :enrollments

  has_many :questions, dependent: :destroy, through: :enrollments

  has_many :question_states, -> { order('question_states.id DESC') }, through: :enrollments, dependent: :destroy, source: :question_states

  has_many :settings, as: :resource, dependent: :destroy

  #has_many :oauth_applications, as: :owner

  #has_one :question_state, -> { order('question_states.id DESC') }, through: :enrollments

  def question_state
    QuestionState.joins(:enrollment).where("enrollments.user_id": id).order('question_states.id DESC').first
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[with_role_ransack]
  end

  scope :undiscarded_enrollments, -> {joins(:enrollments).merge(Enrollment.undiscarded)}

  scope :with_course, lambda { |course|
    left_joins(:roles).where("roles.resource_id": course.id)
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
    joins(:roles).where('roles.name IN (?)', names)
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

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.given_name = auth.extra.id_info.given_name
      user.family_name = auth.extra.id_info.family_name
      user.email = auth.extra.id_info.email
    end
  end


  def self.to_csv
    attributes = %w{id given_name family_name}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.find_each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end


  after_create_commit do
    self.settings.create([{ key: "Desktop_Notifications", value: "false"}, { key: "Site Notifications", value: "false"}])
  end



  rolify has_many_through: :enrollments
  devise :omniauthable, omniauth_providers: %i[google_oauth2]
end
