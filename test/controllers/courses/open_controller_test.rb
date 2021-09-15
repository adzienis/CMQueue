require "test_helper"

class Courses::OpenControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get courses_open_index_url
    assert_response :success
  end

  test "should get update" do
    get courses_open_update_url
    assert_response :success
  end
end
