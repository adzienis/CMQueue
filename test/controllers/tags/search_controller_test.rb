require "test_helper"

class Tags::SearchControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tags_search_index_url
    assert_response :success
  end
end
