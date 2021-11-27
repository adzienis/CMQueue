require "test_helper"

class Users::SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get users_settings_index_url
    assert_response :success
  end

  test "should get update" do
    get users_settings_update_url
    assert_response :success
  end
end
