require "test_helper"

class EnrollByCodeControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get enroll_by_code_create_url
    assert_response :success
  end
end
