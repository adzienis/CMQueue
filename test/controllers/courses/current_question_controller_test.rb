require "test_helper"

class Courses::CurrentQuestionControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get courses_current_question_show_url
    assert_response :success
  end
end
