require "test_helper"

class Courses::AnswerControllerTest < ActionDispatch::IntegrationTest
  before do
    sign_in user
  end

  let(:user) { create(:user) }
  let(:course) { create(:course) }

  context "when not handling question" do
    subject { get answer_course_path(course) }

    context "#get show" do
      with_roles_should("redirects to course's queue", :instructor, :ta) do
        subject
        assert_redirected_to queue_course_path(course)
      end

      unauthorized_with_roles(:student) { subject }
    end
  end
end
