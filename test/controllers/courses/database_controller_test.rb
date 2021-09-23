require "test_helper"

class Courses::DatabaseControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get courses_database_index_url
    assert_response :success
  end
end
