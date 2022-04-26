class CertificateAbility < BaseAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?

    @instructor_roles = Course.find_roles([:instructor], user).pluck(:resource_id)

    can :manage, Certificate, Certificate.where(course_id: @instructor_roles)
  end
end
