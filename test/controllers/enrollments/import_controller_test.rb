require "test_helper"

class Enrollments::ImportControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get enrollments_import_index_url
    assert_response :success
  end

  test "should get create" do
    get enrollments_import_create_url
    assert_response :success
  end
end
