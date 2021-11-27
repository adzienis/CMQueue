require "test_helper"

class Courses::Queue::StaffLogControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get courses_queue_staff_log_show_url
    assert_response :success
  end
end
