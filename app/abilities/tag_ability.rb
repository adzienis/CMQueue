class TagAbility < BaseAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?

    @privileged_roles = Course.find_privileged_staff_roles(user).pluck(:resource_id)
    @staff_roles = Course.find_staff_roles(user).pluck(:resource_id)

    return unless @staff_roles.present?

    can [:search, :read], Tag

    return unless @privileged_roles.present?

    can [:read, :create, :edit, :destroy], Tag, Tag.where(course_id: @privileged_roles) do |tag|
      user.privileged_staff_of?(tag.course)
    end
  end
end
