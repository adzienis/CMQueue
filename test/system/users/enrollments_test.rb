require "application_system_test_case"

class Users::EnrollmentsTest < ApplicationSystemTestCase

  test "visiting the index" do
    sign_in users(:arthur)

    visit current_user_enrollments_url

    assert page.all("a[id^='enrollment_']").count == 1
  end

  test "index has add course by code" do
    sign_in users(:arthur)

    visit current_user_enrollments_url

    assert page.all("div[id=add-course-by-code]").count == 1
  end

  test "index has add course by searc" do
    sign_in users(:arthur)

    visit current_user_enrollments_url

    assert page.all("div[id=search-course]").count == 1
  end
end
