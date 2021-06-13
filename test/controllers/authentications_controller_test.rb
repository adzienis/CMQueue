require "test_helper"

class AuthenticationsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get authentications_create_url
    assert_response :success
  end
end
