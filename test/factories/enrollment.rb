FactoryBot.define do
  factory :enrollment do
    association :role
    association :user
    semester { Enrollment.default_semester }

    factory :ta do
      transient do
        course { create(:course) }
      end

      role { course.ta_role }

    end

    factory :instructor do
      transient do
        course { create(:course) }
      end
      role { course.instructor_role }

    end
    factory :student do
      transient do
        course { create(:course) }
      end

      role { course.student_role }
    end
  end
end
