require "test_helper"

class Enrollments::EnrollBySearchControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get enrollments_enroll_by_search_create_url
    assert_response :success
  end
end
