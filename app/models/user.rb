class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[google_oauth2]

  has_many :enrollments
  has_many :courses, through: :enrollments

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.given_name = auth.extra.id_info.given_name
      user.family_name = auth.extra.id_info.family_name
      user.email = auth.extra.id_info.email
    end
  end
end
