module CourseScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_course_scoped
  end

  private

  def set_course_scoped
    @courses = Course.accessible_by(current_ability)
    @course = @courses.find(params[:course_id]) if params[:course_id]
  end
end
