require "test_helper"

class Users::ImpersonateControllerTest < ActionDispatch::IntegrationTest
  test "should get start_impersonating" do
    get users_impersonate_start_impersonating_url
    assert_response :success
  end

  test "should get stop_impersonating" do
    get users_impersonate_stop_impersonating_url
    assert_response :success
  end
end
