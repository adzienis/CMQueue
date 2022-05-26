require "test_helper"

class Enrollments::ImportControllerTest < ActionDispatch::IntegrationTest
  before do
    sign_in user
  end

  let(:user) { create(:user) }
  let(:course) { create(:course) }

  context "#get index" do
    with_roles_should("succeed", :instructor) do
      it "succeeds" do
        get import_course_enrollments_path(course)
        assert_response :success
      end
    end

    unauthorized_with_roles(:ta, :student) do
      get import_course_enrollments_path(course)
    end
  end

  context "#post create" do
    unauthorized_with_roles(:ta, :student) do
      post import_course_enrollments_path(course)
    end

    with_roles_should("succeed", :instructor) do
      it "succeeds" do
        perform_enqueued_jobs do
          post import_course_enrollments_path(course), params: {
            file: fixture_file_upload("canvas_enrollments.json")
          }
          assert flash[:success] == "Your enrollment import has begun. You will be notified when your import is finished.",
                 "flash is set correctly"
          assert_redirected_to search_course_enrollments_path(course), "redirected to enrollments"
        end

        assert course.instructors.count == 4, "instructors count is accurate"
        assert course.students.count == 15, "students count is accurate"
        assert course.tas.count == 4, "tas count is accurate"
      end
    end
  end
end
