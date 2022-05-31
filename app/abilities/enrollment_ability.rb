class EnrollmentAbility < BaseAbility
  include CanCan::Ability

  def initialize(user, context)
    can :read, Enrollment, Enrollment.where(user: user) do |enrollment|
      enrollment.user == user
    end
  end
end
