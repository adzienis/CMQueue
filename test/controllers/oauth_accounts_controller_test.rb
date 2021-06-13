require "test_helper"

class OauthAccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get create_or_update" do
    get oauth_accounts_create_or_update_url
    assert_response :success
  end

  test "should get error" do
    get oauth_accounts_error_url
    assert_response :success
  end
end
