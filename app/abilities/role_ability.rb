class RoleAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?

    @privileged_roles = Course.find_privileged_staff_roles(user).pluck(:resource_id)

    can :manage, Role, Role.where(resource_id: @privileged_roles) do |role|
      (role.new_record? && user.has_role?(:instructor, :any)) || user.instructor_of?(role.course)
    end
  end
end

