require "test_helper"

class Courses::QueuedQuestionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get courses_queued_questions_index_url
    assert_response :success
  end
end
