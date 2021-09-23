require "test_helper"

class Forms::QuestionControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get forms_question_create_url
    assert_response :success
  end

  test "should get update" do
    get forms_question_update_url
    assert_response :success
  end

  test "should get show" do
    get forms_question_show_url
    assert_response :success
  end
end
