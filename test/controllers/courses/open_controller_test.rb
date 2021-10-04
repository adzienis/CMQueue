require "test_helper"

class Courses::OpenControllerTest < ControllerTest

  test "can get show if instructor" do
    sign_in @instructor

    get open_course_path(@course), params: {
      format: :json
    }

    assert_response :success
  end

  test "can get show if ta" do
    sign_in @ta

    get open_course_path(@course), params: {
      format: :json
    }

    assert_response :success
  end

  test "can get show if student" do
    sign_in @student

    get open_course_path(@course), params: {
      format: :json
    }

    assert_response :success
  end

  test "can patch update if instructor" do
    sign_in @instructor

    @course.update(open: false)

    patch open_course_path(@course), params: {
      format: :json,
      course: {
        open: true
      }
    }

    assert_response :success
  end

  test "can patch update if ta" do
    sign_in @ta

    patch open_course_path(@course), params: {
      format: :json,
      course: {
        open: true
      }
    }
    assert_response :success
  end

  test "patch update changes open" do
    sign_in @instructor

    @course.update(open: false) and @course.reload
    assert(@course.open == false)

    patch open_course_path(@course), params: {
      format: :json,
      course: {
        open: true
      }
    }

    @course.update(open: true) and @course.reload

    assert(@course.open == true)

    assert_response :success
  end

end
