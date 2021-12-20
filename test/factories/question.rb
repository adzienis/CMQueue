FactoryBot.define do
  factory :question do
    enrollment
    description { FFaker::Lorem.paragraph }
    location { FFaker::Lorem.paragraph }
    tried { FFaker::Lorem.paragraph }
  end
end
