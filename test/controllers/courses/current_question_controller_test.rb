require "test_helper"

class Courses::CurrentQuestionControllerTest < ActionDispatch::IntegrationTest
  before do
    sign_in user
  end

  let(:user) { create(:user) }
  let(:course) { create(:course, open: true) }

  context "#get show" do
    let(:user) { create(:user) }
    let(:question) { create(:question, enrollment: user.enrollment_in_course(course)) }

    with_roles_should_ctxt(:student) do
      before do
        question
      end

      context "with unresolved question" do
        let(:question) { create(:question, enrollment: user.enrollment_in_course(course)) }

        it "should return question" do
          get current_question_course_path(course), as: :json

          assert_response :success, "response not success"
          assert JSON.parse(response.body)["id"] == question.id, "parsed body id != question id"
        end
      end

      context "with frozen question" do
        let(:question) { create(:question, :frozen, enrollment: user.enrollment_in_course(course)) }
        it "should return question" do
          get current_question_course_path(course), as: :json

          assert_response :success, "response not success"
          assert JSON.parse(response.body)["id"] == question.id, "parsed body id != question id"
        end
      end

      context "with resolving question" do
        let(:question) { create(:question, :resolving, enrollment: user.enrollment_in_course(course)) }
        it "should return question" do
          get current_question_course_path(course), as: :json

          assert_response :success, "response not success"
          assert JSON.parse(response.body)["id"] == question.id, "parsed body id != question id"
        end
      end

      context "with kicked question" do
        let(:question) { create(:question, :kicked, enrollment: user.enrollment_in_course(course)) }
        it "should be nil" do
          get current_question_course_path(course), as: :json

          assert_response :success, "response not success"
          assert JSON.parse(response.body).nil?, "parsed body is not nil"
        end
      end

      context "with resolved question" do
        let(:question) { create(:question, :resolved, enrollment: user.enrollment_in_course(course)) }
        it "should be nil" do
          get current_question_course_path(course), as: :json

          assert_response :success, "response not success"
          assert JSON.parse(response.body).nil?, "parsed body is not nil"
        end
      end
    end
  end
end
