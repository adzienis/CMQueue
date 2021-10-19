require "test_helper"

class Courses::QuestionsCountControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get courses_questions_count_show_url
    assert_response :success
  end
end
