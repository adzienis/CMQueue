class UserAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?

    can :manage, User, User.where(id: user.id) do |tested_user|
      tested_user == user
    end

    can :read, User

    can :enroll_user, User do |u|
      user.id == u.id
    end

  end
end