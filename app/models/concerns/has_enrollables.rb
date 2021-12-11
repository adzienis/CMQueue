module HasEnrollables
  extend ActiveSupport::Concern
  included do
    resourcify

    has_many :roles, as: :resource, dependent: :destroy
    has_many :enrollments, through: :roles
    has_many :users, through: :enrollments
    has_many :instructors, -> { joins(:role).undiscarded.with_course_roles("instructor") },
      class_name: "Enrollment",
      source: :enrollments,
      through: :roles

    has_many :tas, -> { joins(:role).undiscarded.with_course_roles("ta") },
      class_name: "Enrollment",
      source: :enrollments,
      through: :roles

    has_many :staff,
      -> { joins(:role).undiscarded.with_course_roles("lead_ta", "ta", "instructor").distinct },
      class_name: "Enrollment",
      source: :enrollments,
      through: :roles

    has_many :lead_tas,
      -> { joins(:role).undiscarded.with_course_roles("lead_ta") },
      class_name: "Enrollment",
      source: :enrollments,
      through: :roles

    has_many :students,
      -> { joins(:role).undiscarded.with_course_roles("student") },
      class_name: "Enrollment",
      source: :enrollments,
      through: :roles

    def actively_answering_staff
      staff.joins(:question_states, :user)
        .where("question_states.id in (select max(question_states.id) from question_states " \
                    "group by question_states.enrollment_id)").where("question_states.created_at > ?", 15.minutes.ago)
        .group("enrollments.id")
    end

    def active_tas
      tas.merge(Enrollment.undiscarded)
    end

    def tas
      enrollments.joins(:role).where("roles.name": "ta")
    end

    def active_instructors
      instructors.merge(Enrollment.undiscarded)
    end

    def instructors
      enrollments.joins(:role).where("roles.name": "instructor")
    end

    def active_students
      students.merge(Enrollment.undiscarded)
    end

    def students
      enrollments.joins(:role).where("roles.name": "student")
    end
  end
end
