module Courses
  class StaffInfoPanelComponent < ViewComponent::Base
    def initialize(course:)
      @course = course
    end

    private

    attr_reader :course
  end
end