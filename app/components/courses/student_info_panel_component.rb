module Courses
  class StudentInfoPanelComponent < ViewComponent::Base
    def initialize(course:, question:)
      @question = question
      @course = course
    end

    private

    attr_reader :question, :course
  end
end
