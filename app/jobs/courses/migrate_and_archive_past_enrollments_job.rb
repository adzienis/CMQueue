class Courses::MigrateAndArchivePastEnrollmentsJob < ApplicationJob
  queue_as :default

  def perform
    instructor_enrollments = Enrollment.active.joins(:role).where("enrollments.semester != ?", Enrollment.default_semester)
      .where("roles.name in (?)", [:instructor])
    enrollments = Enrollment.active.joins(:role).where("enrollments.semester != ?", Enrollment.default_semester)
      .where("roles.name in (?)", [:student, :ta])

    ActiveRecord::Base.transaction do
      instructor_enrollments.each do |e|
        e.update!(archived_at: Date.current)
        Courses::Enroll.new(role_name: e.role.name, user: e.user, course: e.course).call
      end

      enrollments.each do |e|
        e.update!(archived_at: Date.current)
      end
    end
  end
end
