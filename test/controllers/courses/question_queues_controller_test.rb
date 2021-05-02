require "test_helper"

class Courses::QuestionQueuesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get courses_question_queues_create_url
    assert_response :success
  end

  test "should get index" do
    get courses_question_queues_index_url
    assert_response :success
  end

  test "should get show" do
    get courses_question_queues_show_url
    assert_response :success
  end
end
