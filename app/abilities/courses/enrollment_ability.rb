module Courses
  class EnrollmentAbility
    include CanCan::Ability

    def initialize(user, context)
      return unless user.present?

      @course = Course.find(context[:params][:course_id]) if context[:params][:course_id].present?

      return unless @course.present?

      @staff_role = Course.find_staff_roles(user).find_by(resource: @course)
      @instructor_role = Course.find_roles([:instructor], user).find_by(resource: @course)

      return unless @staff_role.present?

      can :read, Enrollment, Enrollment.joins(:role).where(user: user).or(Enrollment.where("roles.resource": @staff_role)) do |enrollment|
        (enrollment.user == user) || user.staff_of?(enrollment.course)
      end

      can :search, Enrollment

      return unless @instructor_role.present?

      can [:import, :audit], Enrollment

      can [:new, :edit], Enrollment do |enrollment|
        next true if enrollment.user == user
        next true if user.instructor_of?(enrollment.course)
        if context[:params][:enrollment].present?
          next false if Role.higher_security?(Role.find(context[:params][:enrollment][:role_id]), enrollment.role)
        end
        enrollment.new_record?
      end

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