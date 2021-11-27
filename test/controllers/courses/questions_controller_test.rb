require "test_helper"

class Courses::QuestionsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get courses_questions_edit_url
    assert_response :success
  end

  test "should get update" do
    get courses_questions_update_url
    assert_response :success
  end
end
