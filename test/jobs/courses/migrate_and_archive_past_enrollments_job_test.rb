require "test_helper"

class Courses::MigrateAndArchivePastEnrollmentsJobTest < ActiveJob::TestCase
  let!(:current_tas) { create_list(:ta, 5, course: course, semester: Enrollment.default_semester) }
  let!(:current_students) { create_list(:student, 5, course: course, semester: Enrollment.default_semester) }
  let!(:current_instructors) { create_list(:instructor, 5, course: course, semester: Enrollment.default_semester) }

  let!(:old_tas) { create_list(:ta, 3, course: course, semester: "S21") }
  let!(:old_students) { create_list(:student, 4, course: course, semester: "S21") }
  let!(:old_instructors) { create_list(:instructor, 5, course: course, semester: "S21") }
  let!(:course) { create(:course) }

  it "migrates enrollments correctly" do
    Courses::MigrateAndArchivePastEnrollmentsJob.perform_now

    assert Enrollment.active.count == 20
    assert course.students.active.count == 5
    assert course.tas.active.count == 5
    assert course.instructors.active.count == 10

    old_students.each(&:reload)
    old_tas.each(&:reload)
    old_instructors.each(&:reload)

    assert old_tas.count(&:active?) == 0
    assert old_instructors.count(&:active?) == 0
    assert old_students.count(&:active?) == 0
  end
end
