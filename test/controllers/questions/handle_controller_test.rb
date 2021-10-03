require "test_helper"

class Questions::HandleControllerTest < ControllerTest
  test "can post create if instructor" do
    sign_in @instructor

    get handle_question_path(@course), params: {
      format: :json
    }

    assert_response :success
  end

  test "can post create if ta" do
    sign_in @ta

    get open_course_path(@course), params: {
      format: :json
    }

    assert_response :forbidden
  end

  test "cannot post create if student" do
    sign_in @student

    get open_course_path(@course), params: {
      format: :json
    }

    assert_response :forbidden
  end

end
