class User < ApplicationRecord
  rolify
  devise :omniauthable, omniauth_providers: %i[google_oauth2]

  has_and_belongs_to_many :courses

  has_many :questions, dependent: :destroy

  has_many :question_states, -> { order('question_states.id DESC') }

  has_one :question_state, -> { order('question_states.id DESC') }

  scope :resolved_questions, ->() {
    joins(:question_states)
      .where("question_states.state": "resolved")
  }



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
