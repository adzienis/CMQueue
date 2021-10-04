require "test_helper"

class ControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @course = courses(:class_418)
    @ta = users(:arthur)
    @tag = @course.tags.first
    @instructor = users(:brian)
    @student = users(:jason)
    @student_with_question = users(:max)
    @tim = users(:tim)
    @question = questions(:student_question)
    @tim_question = questions(:tim_question)
    @no_enrollments_user = users(:no_enrollments)
  end
end
