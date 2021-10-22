module Analytics
  class CourseAbility
    include CanCan::Ability

    def initialize(user, context)
      return unless user.present?

      @staff_roles = Course.find_staff_roles(user).pluck(:resource_id)

      can :manage, Dashboard, Dashboard.where(course_id: @staff_roles) do |dashboard|
        dashboard.new_record? || user.privileged_staff_of?(dashboard.course)
      end

    end
  end
end