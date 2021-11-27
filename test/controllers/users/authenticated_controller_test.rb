require "test_helper"

class Users::AuthenticatedControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get users_authenticated_show_url
    assert_response :success
  end
end
