require "test_helper"

class Questions::AcknowledgeControllerTest < ActionDispatch::IntegrationTest
  test "should get update" do
    get questions_acknowledge_update_url
    assert_response :success
  end
end
