module Forms
  module Courses
    module Questions
      class ManageQuestionFormComponent < ViewComponent::Base
        def initialize(manage_question_form:, course:, current_user:)
          @manage_question_form = manage_question_form
          @course = course
          @current_user = current_user
        end

        def question
          manage_question_form.question
        end

        def url
          course_question_path(course)
        end

        private

        attr_reader :manage_question_form, :course, :current_user
      end
    end
  end
end
