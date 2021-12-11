class UserAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?

    can :read, User, User.where(id: user.id) do |tested_user|
      tested_user == user
    end
    can :edit, User, User.where(id: user.id) do |tested_user|
      tested_user == user
    end
    can :create, User, User.where(id: user.id) do |tested_user|
      tested_user == user
    end
    can :destroy, User, User.where(id: user.id) do |tested_user|
      tested_user == user
    end

    can :enroll_user, User do |u|
      user.id == u.id
    end
  end
end
