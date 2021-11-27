module Analytics
  class DashboardAbility
    include CanCan::Ability

    def initialize(user, context)
      return unless user.present?

      @privileged_roles = Course.find_privileged_staff_roles(user).pluck(:resource_id)

      if @privileged_roles.present?
        can :read, Dashboard, Dashboard.where(course_id: @privileged_roles) do |dashboard|
          dashboard.new_record? || user.privileged_staff_of?(dashboard.course)
        end
        can :create, Dashboard, Dashboard.where(course_id: @privileged_roles) do |dashboard|
          dashboard.new_record? || user.privileged_staff_of?(dashboard.course)
        end
        can :edit, Dashboard, Dashboard.where(course_id: @privileged_roles) do |dashboard|
          dashboard.new_record? || user.privileged_staff_of?(dashboard.course)
        end
        can :destroy, Dashboard, Dashboard.where(course_id: @privileged_roles) do |dashboard|
          dashboard.new_record? || user.privileged_staff_of?(dashboard.course)
        end
      end
    end
  end
end
