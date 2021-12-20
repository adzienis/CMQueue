require "test_helper"

class Courses::OpenControllerTest < ActionDispatch::IntegrationTest
  before do
    sign_in user
  end

  let(:user) { create(:user) }
  let(:course) { create(:course) }

  context "#get show" do
    subject { get open_course_path(course), as: :json }

    context "json" do
      with_roles_should("succeeds", :instructor, :ta) do
        get open_course_path(course), as: :json
        assert_response :success
      end

      unauthorized_with_roles(:student) { subject }
    end
  end

  context "#patch update" do
    subject do
      patch open_course_path(course), params: {
        course: {
          open: true
        }
      }, as: :json
    end

    context "json" do
      with_roles_should("succeeds", :instructor, :ta) do
        subject

        assert_response :success
        assert course.reload.open?
      end

      unauthorized_with_roles(:student) { subject }
    end
  end
end
