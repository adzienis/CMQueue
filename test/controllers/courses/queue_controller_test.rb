require "test_helper"

class Courses::QueueControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get courses_queue_index_url
    assert_response :success
  end
end
