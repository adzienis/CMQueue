require "test_helper"

class Enrollments::SearchControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get enrollments_search_index_url
    assert_response :success
  end
end
