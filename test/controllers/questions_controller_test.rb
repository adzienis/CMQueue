require "test_helper"

class QuestionsControllerTest < ControllerTest
  setup do
  end

  test "can get own questions" do
    sign_in @student

    get user_questions_path(@student)

    assert_response :success
  end

  test "cannot get other users questions" do
    sign_in @student

    get user_questions_path(@ta)

    assert_response :forbidden
  end

  test "can create own question if student" do
    sign_in @student

    post course_questions_path(@course), params: {
      question: {
        enrollment_id: @student.enrollment_in_course(@course),
        description: "blah",
        location: "blah",
        tried: "blah",
        tag_ids: [@tag.id]
      }
    }

    assert_response :success
  end

  test "cannot get course questions if student" do
    sign_in @student

    get course_questions_path(@course)

    assert_response :forbidden
  end

  test "can get course questions if ta" do
    sign_in @ta

    get course_questions_path(@course)

    assert_response :success
  end

  test "can get course questions if instructor" do
    sign_in @instructor

    get course_questions_path(@course)

    assert_response :success
  end

  test "can update course questions if instructor" do
    sign_in @instructor

    patch course_question_path(@course, @question), params: {
      question: {
        description: "another"
      }
    }

    assert_response :redirect
  end

  test "cannot update course questions if ta" do
    sign_in @instructor

    patch course_question_path(@course, @question), params: {
      question: {
        description: "another"
      }
    }

    assert_response :redirect
  end

  test "can update own questions" do
    sign_in @student_with_question

    patch course_question_path(@course, @question), params: {
      question: {
        description: "another"
      }
    }

    assert_response :redirect
  end

  test "cannot update other users questions if not instructor" do
    sign_in @student

    patch course_question_path(@course, @tim_question), params: {
      question: {
        description: "another"
      }
    }

    assert_response :forbidden
  end



end
