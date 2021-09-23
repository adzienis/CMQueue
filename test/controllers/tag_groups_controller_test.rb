require "test_helper"

class TagGroupsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tag_groups_index_url
    assert_response :success
  end

  test "should get show" do
    get tag_groups_show_url
    assert_response :success
  end

  test "should get create" do
    get tag_groups_create_url
    assert_response :success
  end

  test "should get edit" do
    get tag_groups_edit_url
    assert_response :success
  end

  test "should get destroy" do
    get tag_groups_destroy_url
    assert_response :success
  end
end
