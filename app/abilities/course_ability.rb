class CourseAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?

    @instructor_roles = Course.find_roles([:instructor], user).pluck(:resource_id)
    @privileged_roles = Course.find_privileged_staff_roles(user).pluck(:resource_id)
    @staff_roles = Course.find_staff_roles(user).pluck(:resource_id)

    can :queue, Course

    can [:active_tas, :read, :search], Course
    can :semester, Course

    cannot :read, Course, [:instructor_code] do |course|
      !user.instructor_of?(course.id)
    end

    cannot :read, Course, [:ta_code] do |course|
      !user.staff_of?(course)
    end

    can [:course_info, :roster, :open,
         :update, :top_question, :answer, :answer_page], Course, Course.where(id: @staff_roles) do |course|
      user.staff_of?(course)
    end

    can :manage, Course, Course.where(id: @instructor_roles) do |course|
      user.instructor_of?(course)
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

