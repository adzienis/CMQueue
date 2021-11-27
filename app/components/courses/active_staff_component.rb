module Courses
  class ActiveStaffComponent < QueueInfoComponent
    def initialize(course:)
      super
      @course = course
    end

    def title
      "Active Staff"
    end

    def footer
    end

    def info
      nil
    end

    def value_style
      ""
    end

    def value
      course.actively_answering_staff.map{|e| e.user.full_name}.join(", ")
    end

    private

    attr_reader :course
  end
end
