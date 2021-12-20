FactoryBot.define do
  factory :course do
    sequence(:name) { |n| "course_#{n}" }
  end
end
