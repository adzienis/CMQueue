require "test_helper"

class SettingsControllerTest < ControllerTest
  test "can index own settings" do
    sign_in @student

    get user_settings_path(@student)

    assert_response :success
  end

  test "cannot index course settings if student" do
    sign_in @student

    get course_settings_path(@course)

    assert_response :forbidden
  end

  test "cannot index course settings if ta" do
    sign_in @ta

    get course_settings_path(@course)

    assert_response :forbidden
  end

  test "can index course settings if instructor" do
    sign_in @instructor

    get course_settings_path(@course)

    assert_response :success
  end

  test "cannot update course settings if student" do
    sign_in @student

    @course.settings.create

    patch course_setting_path(@course, @course.settings.first), params: {
      setting: {
        value: 1
      }
    }

    assert_response :forbidden
  end

  test "cannot update course settings if ta" do
    sign_in @ta
    @course.settings.create

    patch course_setting_path(@course, @course.settings.first), params: {
      setting: {
        value: 1
      }
    }

    assert_response :forbidden
  end

  test "can update course settings if instructor" do
    sign_in @instructor
    @course.settings.create(value: {
      test_setting: {
        value: nil
      }
    })

    patch course_setting_path(@course, @course.settings.first), params: {
      setting: {
        value: 1
      }
    }

    assert_response :forbidden
  end
end
