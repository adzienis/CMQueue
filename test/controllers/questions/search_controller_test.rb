require "test_helper"

class Questions::SearchControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get questions_search_index_url
    assert_response :success
  end
end
