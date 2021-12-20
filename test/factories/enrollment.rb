FactoryBot.define do
  factory :enrollment do
    association :role
    association :user
  end
end
