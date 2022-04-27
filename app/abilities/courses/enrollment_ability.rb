module Courses
  class EnrollmentAbility < BaseAbility
    include CanCan::Ability

    def initialize(user, context)
      super

      return unless enrollment.staff?

      can :read, Enrollment, Enrollment.joins(:role).where(user: user).or(Enrollment.where("roles.resource": enrollment.course)) do |enrollment|
        (enrollment.user == user) || user.staff_of?(enrollment.course)
      end

      can :search, Enrollment

      return unless enrollment.instructor?

      can [:import, :audit, :new, :edit], Enrollment

      can :create, Enrollment do |enrollment|
        (enrollment.user == user && enrollment.role.name == "student") || user.instructor_of?(enrollment.course)
      end

      can :destroy, Enrollment, Enrollment.joins(:role).where(user: user).or(Enrollment.where("roles.resource": @staff_role)) do |enrollment|
        (enrollment.user == user) || user.instructor_of?(enrollment.course)
      end

      can :update, Enrollment, Enrollment.joins(:role).where(user: user).or(Enrollment.where("roles.resource": @staff_role)) do |enrollment|
        next true if user.instructor_of?(enrollment.course)
        if context[:params][:enrollment].present?
          next false if Role.higher_security?(Role.find(context[:params][:enrollment][:role_id]), enrollment.role)
        end
        (enrollment.user == user)
      end
    end
  end

end