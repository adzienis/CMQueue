module CourseFilterable
  extend ActiveSupport::Concern

  included do
    before_action :set_course_filtered
  end

  private

  def set_course_filtered
    resources = proc { instance_variable_get("@#{controller_name}") }
    set_resources = proc { |value| instance_variable_set("@#{controller_name}", value) }

    set_resources.call(resources.call.with_courses(params[:course_id])) if params[:course_id]
  end
end
