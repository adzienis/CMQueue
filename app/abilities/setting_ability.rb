class SettingAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?

    @instructor_roles = Course.find_roles([:instructor], user).pluck(:resource_id)

    can :manage, Setting, Setting.where(resource_id: user.id, resource_type: "User")
                                 .or(Setting.where(resource_id: @instructor_roles, resource_type: "Course")) do |setting|
      case setting.resource_type
      when "User"
        user.id == setting.resource_id
      when "Course"
        user.instructor_of?(setting.resource_id)
      end
    end
  end
end

