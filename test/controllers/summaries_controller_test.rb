require "test_helper"

class SummariesControllerTest < ActionDispatch::IntegrationTest
  test "should get activity" do
    get summaries_activity_url
    assert_response :success
  end

  test "should get answer_time" do
    get summaries_answer_time_url
    assert_response :success
  end
end
