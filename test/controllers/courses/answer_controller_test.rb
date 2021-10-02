require "test_helper"

class Courses::AnswerControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @course = courses(:class_418)
    @ta = users(:arthur)
    @instructor = users(:brian)
    @student = users(:jason)
  end

  test "can access if instructor" do
    sign_in @instructor

    get answer_course_path(@course)

    assert_response :success
  end

  test "can access if ta" do
    sign_in @ta

    get answer_course_path(@course)

    assert_response :success
  end

  test "cannot access if student" do
    sign_in @student

    get answer_course_path(@course)

    assert_response :forbidden
  end
end
