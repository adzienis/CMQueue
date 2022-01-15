FactoryBot.define do
  factory :user do
    given_name { "bob" }
    family_name { "joe" }
    sequence(:email) { |n| "email#{n}@gmail.com" }

    factory :user_as_student do
      transient do
        course { create(:course) }
        semester { Enrollment.default_semester }
      end

      after(:create) do |user, evaluator|
        create(:enrollment, role: evaluator.course.student_role, user: user, semester: evaluator.semester)
        user.reload
      end
    end

    factory :user_as_ta do
      transient do
        course { create(:course) }
        semester { Enrollment.default_semester }
      end

      after(:create) do |user, evaluator|
        create(:enrollment, role: evaluator.course.ta_role, user: user, semester: evaluator.semester)
        user.reload
      end
    end

    factory :user_as_instructor do
      transient do
        course { create(:course) }
        semester { Enrollment.default_semester }
      end

      after(:create) do |user, evaluator|
        create(:enrollment, role: evaluator.course.instructor_role, user: user, semester: evaluator.semester)
        user.reload
      end
    end
  end
end
