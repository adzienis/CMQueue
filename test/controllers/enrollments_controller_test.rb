require "test_helper"

class EnrollmentsControllerTest < ControllerTest
  setup do
  end

  test "can get own enrollments" do
    sign_in @instructor

    get user_enrollments_path(@instructor)

    assert_response :success
  end

  test "can get course enrollments if instructor" do
    sign_in @instructor

    get course_enrollments_path(@course)

    assert_response :success
  end
  test "can get course enrollments if ta" do
    sign_in @ta

    get course_enrollments_path(@course)

    assert_response :success
  end

  test "cannot get course enrollments if student" do
    sign_in @student

    get course_enrollments_path(@course)

    assert_response :forbidden
  end

  test "can create own enrollments" do
    sign_in @no_enrollments_user

    post course_enrollments_path(@course), params: {
      enrollment: {
        user_id: @no_enrollments_user.id,
        role_id: @course.student_role.id
      }
    }
    assert_response :redirect
  end

  test "cannot enroll self as instructor" do
    sign_in @no_enrollments_user

    post course_enrollments_path(@course), params: {
      enrollment: {
        user_id: @no_enrollments_user.id,
        role_id: @course.instructor_role.id
      }
    }
    assert_response :forbidden
  end

  test "cannot enroll self as ta" do
    sign_in @no_enrollments_user

    post course_enrollments_path(@course), params: {
      enrollment: {
        user_id: @no_enrollments_user.id,
        role_id: @course.ta_role.id
      }
    }
    assert_response :forbidden
  end

  test "cannot create own enrollments if role is ta" do
    sign_in @no_enrollments_user

    post course_enrollments_path(@course), params: {
      enrollment: {
        user_id: @no_enrollments_user.id,
        role_id: @course.ta_role.id
      }
    }
    assert_response :forbidden
  end

  test "can create course enrollments if instructor" do
    sign_in @instructor

    post course_enrollments_path(@course), params: {
      enrollment: {
        user_id: @no_enrollments_user.id,
        role_id: @course.student_role.id
      }
    }

    assert_response :redirect
  end
  test "cannot create course enrollments for others if ta" do
    sign_in @ta

    post course_enrollments_path(@course), params: {
      enrollment: {
        user_id: @no_enrollments_user.id,
        role_id: @course.student_role.id
      }
    }

    assert_response :forbidden
  end

  test "cannot create course enrollments for others if student" do
    sign_in @student

    post course_enrollments_path(@course), params: {
      enrollment: {
        user_id: @no_enrollments_user.id,
        role_id: @course.student_role.id
      }
    }

    assert_response :forbidden
  end

  test "cannot upgrade own role" do
    sign_in @student

    patch course_enrollment_path(@course, @student.enrollments.joins(:role).find_by(role: @course.student_role)), params: {
      enrollment: {
        role_id: @course.instructor_role.id
      }
    }

    assert_response :forbidden
  end

  test "cannot change other user's role if student" do
    sign_in @student

    patch course_enrollment_path(@course, @tim.enrollments.joins(:role).find_by(role: @course.student_role)), params: {
      enrollment: {
        role_id: @course.student_role.id
      }
    }
    assert_response :forbidden
  end
end
