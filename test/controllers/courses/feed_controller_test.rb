require "test_helper"

class Courses::FeedControllerTest < ActionDispatch::IntegrationTest
  before do
    sign_in user
  end

  let(:user) { create(:user) }
  let(:selected_tags) { nil }
  let(:course) { create(:course, open: true) }

  context "#post answer" do
    subject do
      post feed_answer_course_path(course), params: {
        tags: selected_tags
      }
    end

    unauthorized_with_roles(:student) { subject }

    context "when questions present" do
      let(:user) { create(:user_as_ta, course: course) }
      let(:student_1) { create(:user_as_student, course: course) }
      let(:student_2) { create(:user_as_student, course: course_2) }

      context "multiple courses" do
        let(:course) { create(:course, open: true) }
        let(:course_2) { create(:course, open: true) }

        let(:question_1) { create(:question, enrollment: student_1.enrollment_in_course(course)) }
        let(:question_2) { create(:question, enrollment: student_2.enrollment_in_course(course_2)) }

        before do
          question_1
          question_2
        end

        it "passes" do
          subject

          assert question_1.question_state.resolving?, "answered question is not resolving"
          assert question_2.question_state.unresolved?, "question_2 is not unresolved"
          assert user.handling_question?(course: course), "user is not handling a question"
          assert_redirected_to answer_course_path(course), "user not redirected to answer path"
        end
      end
    end

    context "when multiple questions" do
    end
  end
end
