require "test_helper"

class Courses::Queue::FeedsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get courses_queue_feeds_show_url
    assert_response :success
  end
end
