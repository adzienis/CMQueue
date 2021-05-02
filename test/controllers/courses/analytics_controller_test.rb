require "test_helper"

class Courses::AnalyticsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get courses_analytics_index_url
    assert_response :success
  end
end
