class TagAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?

    @privileged_roles = Course.find_privileged_staff_roles(user).pluck(:resource_id)

    can :read, Tag
    can :create, Tag if (user.roles.where(name: ['ta', 'instructor', 'lead_ta'])).exists?
    can :manage, Tag, Tag.where(course_id: @privileged_roles) do |tag|
      user.privileged_staff_of?(tag.course)
    end
  end
end

