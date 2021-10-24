class TagGroupAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?

    @privileged_roles = Course.find_privileged_staff_roles(user).pluck(:resource_id)

    can :new, TagGroup do |tag_group|
      tag_group.new_record?
    end

    can :manage, TagGroup, TagGroup.where(course_id: @privileged_roles) do |tag_group|
      user.privileged_staff_of?(tag_group.course)
    end
    can :read, TagGroup
  end
end
