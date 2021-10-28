require "test_helper"

class TagGroups::SearchControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tag_groups_search_index_url
    assert_response :success
  end
end
