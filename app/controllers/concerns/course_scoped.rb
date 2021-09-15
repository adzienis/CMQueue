module CourseScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_course
  end

  private

  def set_course
    @course = Course.accessible_by(current_ability).find(params[:course_id])
  end
end