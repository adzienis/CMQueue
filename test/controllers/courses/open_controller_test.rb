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

    assert_response :forbidden
  end

  test "cannot get show if student" do
    sign_in @student

    get open_course_path(@course), params: {
      format: :json
    }

    assert_response :forbidden
  end

  test "can post update if instructor" do
    sign_in @instructor

    get open_course_path(@course), params: {
      format: :json
    }

    assert_response :success
  end



end
