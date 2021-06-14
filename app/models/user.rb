class User < ApplicationRecord
  rolify
  devise :omniauthable, omniauth_providers: %i[google_oauth2]

  has_many :access_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  has_many :enrollments
  has_many :courses, through: :enrollments

  has_many :questions, dependent: :destroy

  has_many :question_states, -> { order('question_states.id DESC') }

  has_one :question_state, -> { order('question_states.id DESC') }

  def self.ransackable_scopes(auth_object = nil)
    %i(with_role_ransack)
  end

  scope :with_course, ->(course) {
    left_joins(:roles).where("roles.resource_id": course.id)
  }

  scope :resolved_questions, ->() {
    joins(:question_states)
      .where("question_states.state": "resolved")
  }

  scope :with_role_ransack, ->(role) do
    if role.to_s == "any"
      joins(:roles).distinct
    else
      joins(:roles).where("roles.name": role.to_s).distinct
    end
  end

  scope :with_any_roles, ->(*names) do
    joins(:roles).where("roles.name IN (?)", names)
  end

  scope :active_tas_by_date, ->(states, date, course) { joins(:question_state)
                                                          .where("question_states.state in (#{states.map { |x| QuestionState.states[x] }.join(',')})")
                                                          .where("question_states.created_at >= ?", date.beginning_of_day)
                                                          .where("question_states.created_at <= ?", date.end_of_day)
                                                          .with_role(:ta, course)
                                                          .distinct("users.id")
  }

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.given_name = auth.extra.id_info.given_name
      user.family_name = auth.extra.id_info.family_name
      user.email = auth.extra.id_info.email
    end
  end
end
