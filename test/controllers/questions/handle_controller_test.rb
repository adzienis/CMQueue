require "test_helper"

class Questions::HandleControllerTest < ControllerTest
  test "can post create if instructor" do
    sign_in @instructor


    post handle_question_path(@question), params: {
      format: :json,
      state: "resolving",
      enrollment_id: @instructor.enrollment_in_course(@course).id
    }

    assert_response :created
  end

  test "can post create if ta" do
    sign_in @ta

    post handle_question_path(@question), params: {
      format: :json,
      state: "resolving",
      enrollment_id: @ta.enrollment_in_course(@course).id
    }

    assert_response :created
  end

  test "cannot post create if student" do
    sign_in @student

    post handle_question_path(@question), params: {
      format: :json,
      state: "resolving",
      enrollment_id: @student.enrollment_in_course(@course).id
    }

    assert_response :forbidden
  end

end
