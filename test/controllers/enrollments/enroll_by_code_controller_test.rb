require "test_helper"

class Enrollments::EnrollByCodeControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get enrollments_enroll_by_code_create_url
    assert_response :success
  end
end
