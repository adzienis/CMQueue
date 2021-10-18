require "application_system_test_case"

class Analytics::DashboardsTest < ApplicationSystemTestCase
  setup do
    @analytics_dashboard = analytics_dashboards(:one)
  end

  test "visiting the index" do
    visit analytics_dashboards_url
    assert_selector "h1", text: "Analytics/Dashboards"
  end

  test "creating a Dashboard" do
    visit analytics_dashboards_url
    click_on "New Analytics/Dashboard"

    fill_in "Course", with: @analytics_dashboard.course_id
    fill_in "Title", with: @analytics_dashboard.title
    fill_in "Url", with: @analytics_dashboard.url
    click_on "Create Dashboard"

    assert_text "Dashboard was successfully created"
    click_on "Back"
  end

  test "updating a Dashboard" do
    visit analytics_dashboards_url
    click_on "Edit", match: :first

    fill_in "Course", with: @analytics_dashboard.course_id
    fill_in "Title", with: @analytics_dashboard.title
    fill_in "Url", with: @analytics_dashboard.url
    click_on "Update Dashboard"

    assert_text "Dashboard was successfully updated"
    click_on "Back"
  end

  test "destroying a Dashboard" do
    visit analytics_dashboards_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Dashboard was successfully destroyed"
  end
end
