require "test_helper"

class Courses::UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get courses_users_new_url
    assert_response :success
  end

  test "should get create" do
    get courses_users_create_url
    assert_response :success
  end
end
