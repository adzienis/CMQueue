require "test_helper"

class Courses::Enrollments::AuditLogsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get courses_enrollments_audit_logs_index_url
    assert_response :success
  end
end
