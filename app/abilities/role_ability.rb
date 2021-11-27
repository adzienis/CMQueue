class RoleAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?

    @privileged_roles = Course.find_privileged_staff_roles(user).pluck(:resource_id)

    return unless @privileged_roles.exist?

    can :read, Role, Role.where(resource_id: @privileged_roles) do |role|
      (role.new_record? && user.has_role?(:instructor, :any)) || user.instructor_of?(role.course)
    end

    can :create, Role, Role.where(resource_id: @privileged_roles) do |role|
      (role.new_record? && user.has_role?(:instructor, :any)) || user.instructor_of?(role.course)
    end

    can :update, Role, Role.where(resource_id: @privileged_roles) do |role|
      (role.new_record? && user.has_role?(:instructor, :any)) || user.instructor_of?(role.course)
    end

    can :destroy, Role, Role.where(resource_id: @privileged_roles) do |role|
      (role.new_record? && user.has_role?(:instructor, :any)) || user.instructor_of?(role.course)
    end
  end
end
