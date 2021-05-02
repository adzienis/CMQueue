require "test_helper"

class Users::EnrollmentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get users_enrollments_index_url
    assert_response :success
  end

  test "should get create" do
    get users_enrollments_create_url
    assert_response :success
  end
end
