require "test_helper"

class Accounts::SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get accounts_settings_index_url
    assert_response :success
  end

  test "should get update" do
    get accounts_settings_update_url
    assert_response :success
  end
end
