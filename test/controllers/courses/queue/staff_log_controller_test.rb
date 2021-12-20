require "test_helper"

class Courses::Queue::StaffLogControllerTest < ActionDispatch::IntegrationTest
  before do
    sign_in user
  end

  let(:user) { create(:user) }
  let(:course) { create(:course) }

  context "#get show" do
    with_roles_should("succeed", :instructor, :ta) do
      get queue_staff_log_course_path(course)
      assert_response :success
    end

    unauthorized_with_roles(:student) do
      get queue_staff_log_course_path(course)
    end
  end
end
