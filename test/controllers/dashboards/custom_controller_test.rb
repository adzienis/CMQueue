require "test_helper"

class Dashboards::CustomControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get dashboards_custom_show_url
    assert_response :success
  end
end
