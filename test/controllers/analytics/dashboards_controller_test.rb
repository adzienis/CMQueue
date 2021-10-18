require "test_helper"

class Analytics::DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @analytics_dashboard = analytics_dashboards(:one)
  end

  test "should get index" do
    get analytics_dashboards_url
    assert_response :success
  end

  test "should get new" do
    get new_analytics_dashboard_url
    assert_response :success
  end

  test "should create analytics_dashboard" do
    assert_difference('Analytics::Dashboard.count') do
      post analytics_dashboards_url, params: { analytics_dashboard: { course_id: @analytics_dashboard.course_id, title: @analytics_dashboard.title, url: @analytics_dashboard.url } }
    end

    assert_redirected_to analytics_dashboard_url(Analytics::Dashboard.last)
  end

  test "should show analytics_dashboard" do
    get analytics_dashboard_url(@analytics_dashboard)
    assert_response :success
  end

  test "should get edit" do
    get edit_analytics_dashboard_url(@analytics_dashboard)
    assert_response :success
  end

  test "should update analytics_dashboard" do
    patch analytics_dashboard_url(@analytics_dashboard), params: { analytics_dashboard: { course_id: @analytics_dashboard.course_id, title: @analytics_dashboard.title, url: @analytics_dashboard.url } }
    assert_redirected_to analytics_dashboard_url(@analytics_dashboard)
  end

  test "should destroy analytics_dashboard" do
    assert_difference('Analytics::Dashboard.count', -1) do
      delete analytics_dashboard_url(@analytics_dashboard)
    end

    assert_redirected_to analytics_dashboards_url
  end
end
