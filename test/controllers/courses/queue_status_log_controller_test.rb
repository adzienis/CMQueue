require "test_helper"

class Courses::QueueStatusLogControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get courses_queue_status_log_index_url
    assert_response :success
  end
end
