require "test_helper"

class Users::ActivityControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get users_activity_index_url
    assert_response :success
  end
end
