class OauthApplication < ApplicationRecord
  has_many :oauth_access_grants, dependent: :destroy, foreign_key: :application_id
  has_many :oauth_access_tokens, dependent: :destroy, foreign_key: :application_id
end
