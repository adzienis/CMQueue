module Courses
  class SettingAbility
    include CanCan::Ability

    def initialize(user, context)
      return unless user.present?

      @privileged_roles = Course.find_privileged_staff_roles(user).pluck(:resource_id)

      return unless @privileged_roles.present?

      can :read, Setting, Setting.where(resource_id: @privileged_roles, resource_type: "Course") do |setting|
        user.instructor_of?(setting.course) if setting.course.present?
      end
      can :create, Setting, Setting.where(resource_id: @privileged_roles, resource_type: "Course") do |setting|
        user.instructor_of?(setting.course) if setting.course.present?
      end
      can :update, Setting, Setting.where(resource_id: @privileged_roles, resource_type: "Course") do |setting|
        user.instructor_of?(setting.course) if setting.course.present?
      end
      can :destroy, Setting, Setting.where(resource_id: @privileged_roles, resource_type: "Course") do |setting|
        user.instructor_of?(setting.course) if setting.course.present?
      end
    end
  end
end
