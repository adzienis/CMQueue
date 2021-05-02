require "test_helper"

class QuestionQueuesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get question_queues_create_url
    assert_response :success
  end

  test "should get show" do
    get question_queues_show_url
    assert_response :success
  end

  test "should get index" do
    get question_queues_index_url
    assert_response :success
  end

  test "should get destroy" do
    get question_queues_destroy_url
    assert_response :success
  end
end
