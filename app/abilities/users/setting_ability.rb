module Users
  class SettingAbility < BaseAbility
    include CanCan::Ability

    def initialize(user, context)
      return unless user.present?

      can :read, Setting, Setting.where(resource_id: user, resource_type: "User") do |setting|
        user == setting.user
      end
      can :create, Setting, Setting.where(resource_id: user, resource_type: "User") do |setting|
        user == setting.user
      end
      can :update, Setting, Setting.where(resource_id: user, resource_type: "User") do |setting|
        user == setting.user
      end
      can :destroy, Setting, Setting.where(resource_id: user.id, resource_type: "User") do |setting|
        user == setting.user
      end
    end
  end
end
