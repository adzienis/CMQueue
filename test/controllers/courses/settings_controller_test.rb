require "test_helper"

class Courses::SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get courses_settings_index_url
    assert_response :success
  end
end
