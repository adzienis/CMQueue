FactoryBot.define do
  factory :question do
    enrollment
    question_state { nil }
    description { FFaker::Lorem.paragraph }
    location { FFaker::Lorem.paragraph }
    tried { FFaker::Lorem.paragraph }

    trait :unresolved do
      after(:create) do |question|
        create(:question_state, question: question, enrollment: question.enrollment, state: "unresolved")
      end
    end

    trait :resolving do
      after(:create) do |question|
        create(:question_state, question: question, enrollment: question.enrollment, state: "resolving")
      end
    end

    trait :frozen do
      after(:create) do |question|
        create(:question_state, question: question, enrollment: question.enrollment, state: "frozen")
      end
    end

    trait :kicked do
      after(:create) do |question|
        create(:question_state, question: question, enrollment: question.enrollment, state: "kicked")
      end
    end

    trait :resolved do
      after(:create) do |question|
        create(:question_state, question: question, enrollment: question.enrollment, state: "resolving")
        create(:question_state, question: question, enrollment: question.enrollment, state: "resolved")
      end
    end
  end
end
