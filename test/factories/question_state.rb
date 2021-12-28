FactoryBot.define do
  factory :question_state do
    question { build(:question) }
    enrollment { build(:enrollment) }
    state { "unresolved" }
  end
end
