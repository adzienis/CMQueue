require "test_helper"

class Forms::QuestionControllerTest < ControllerTest
  test "student with no question can access new" do
    sign_in @student

    get new_course_forms_question_path(@course)

    assert_response :success
  end
end
