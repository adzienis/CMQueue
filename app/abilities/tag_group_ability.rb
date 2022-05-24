class TagGroupAbility < BaseAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?

    @privileged_roles = Course.find_privileged_staff_roles(user).pluck(:resource_id)
    @staff_roles = Course.find_staff_roles(user).pluck(:resource_id)

    return unless @staff_roles.present?

    can [:search, :read], TagGroup, TagGroup.where(course_id: @staff_roles) do |tag_group|
      user.privileged_staff_of?(tag_group.course)
    end

    return unless @privileged_roles.present?

    can [:manage], TagGroup, TagGroup.where(course_id: @privileged_roles) do |tag_group|
      tag_group.new_record? || user.privileged_staff_of?(tag_group.course)
    end
  end
end
