FactoryBot.define do
  factory :role do
    name { "default" }

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
