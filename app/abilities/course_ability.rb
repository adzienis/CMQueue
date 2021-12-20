class CourseAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?

    @instructor_roles = Course.find_roles([:instructor], user).pluck(:resource_id)
    @privileged_roles = Course.find_privileged_staff_roles(user).pluck(:resource_id)
    @staff_roles = Course.find_staff_roles(user).pluck(:resource_id)
    @course = Course.find(context[:params][:course_id]) if context[:params][:course_id]

    if @course.present?
      if user.staff_of?(@course)
        can [:read_open, :update_open, :answer], @course
        can :queue, Course
        can :semester, Course
        can :read, :staff_log
      end
    end

    can :active_tas, Course

    can [:course_info, :roster, :open,
      :update, :top_question, :answer, :answer_page], Course, Course.where(id: @staff_roles) do |course|
      user.staff_of?(course)
    end

    can :queue_show, Course, Course.where(id: @staff_roles) do |course|
      user.staff_of?(course)
    end

    can :answer, Course, Course.where(id: @staff_roles) do |course|
      user.staff_of?(course)
    end

    can :index_database, Course do |course|
      user.privileged_staff_of?(course)
    end
  end
end
