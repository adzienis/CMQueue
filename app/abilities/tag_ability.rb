class TagAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?

    @privileged_roles = Course.find_privileged_staff_roles(user).pluck(:resource_id)
    @staff_roles = Course.find_staff_roles(user).pluck(:resource_id)

    can :search, Tag if @staff_roles.any?

    can :read, Tag
    can :create, Tag if user.roles.where(name: ["ta", "instructor", "lead_ta"]).exists?
    can [:read, :create, :edit, :destroy], Tag, Tag.where(course_id: @privileged_roles) do |tag|
      user.privileged_staff_of?(tag.course)
    end
  end
end
