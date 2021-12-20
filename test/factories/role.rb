FactoryBot.define do
  factory :role do
    association :resource

    trait :instructor do
      name { "instructor" }
    end
    trait :student do
      name { "student" }
    end
    trait :ta do
      name { "ta" }
    end
    trait :lead_ta do
      name { "lead_ta" }
    end
  end
end
