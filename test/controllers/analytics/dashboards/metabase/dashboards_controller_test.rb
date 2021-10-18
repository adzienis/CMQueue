require "test_helper"

class Analytics::Dashboards::Metabase::DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get analytics_dashboards_metabase_dashboards_index_url
    assert_response :success
  end
end
