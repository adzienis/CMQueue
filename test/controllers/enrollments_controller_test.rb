require "test_helper"

class EnrollmentsControllerTest < ControllerTest
  test "can get own enrollments" do
  end

  test "can get course enrollments if instructor" do
  end
  test "can get course enrollments if ta" do
  end

  test "cannot get course enrollments if student" do
  end

  test "can create own enrollments" do
  end

  test "cannot enroll self as instructor" do
  end

  test "cannot enroll self as ta" do
  end

  test "cannot create own enrollments if role is ta" do
  end

  test "can create course enrollments if instructor" do
  end
  test "cannot create course enrollments for others if ta" do
  end

  test "cannot create course enrollments for others if student" do
  end

  test "cannot upgrade own role" do
  end

  test "cannot change other user's role if student" do
  end
end
