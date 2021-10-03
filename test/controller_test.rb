require "test_helper"

class ControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @course = courses(:class_418)
    @ta = users(:arthur)
    @instructor = users(:brian)
    @student = users(:jason)
  end
end
