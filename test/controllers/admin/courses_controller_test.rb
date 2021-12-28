require "test_helper"

class Admin::CoursesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_courses_index_url
    assert_response :success
  end
end
