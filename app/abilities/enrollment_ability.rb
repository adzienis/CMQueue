class EnrollmentAbility < BaseAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?

    @staff_roles = Course.find_staff_roles(user).pluck(:resource_id)
    @course = Course.find(context[:params][:course_id]) if context[:params][:course_id].present?

    if @course.present?
      can :import, Enrollment if user.instructor_of?(@course)
    end
    binding.pry

    can [:new, :edit], Enrollment do |enrollment|
      next true if enrollment.user == user
      next true if user.instructor_of?(enrollment.course)
      if context[:params][:enrollment].present?
        next false if Role.higher_security?(Role.find(context[:params][:enrollment][:role_id]), enrollment.role)
      end
      enrollment.new_record?
    end

    can :search, Enrollment if @staff_roles.any?

    can :create, Enrollment do |enrollment|
      (enrollment.user == user && enrollment.role.name == "student") || user.instructor_of?(enrollment.course)
    end

    can :read, Enrollment, Enrollment.joins(:role).where(user: user).or(Enrollment.where("roles.resource_id": @staff_roles)) do |enrollment|
      (enrollment.user == user) || user.staff_of?(enrollment.course)
    end

    can :destroy, Enrollment, Enrollment.joins(:role).where(user: user).or(Enrollment.where("roles.resource_id": @staff_roles)) do |enrollment|
      (enrollment.user == user) || user.instructor_of?(enrollment.course)
    end

    can :update, Enrollment, Enrollment.joins(:role).where(user: user).or(Enrollment.where("roles.resource_id": @staff_roles)) do |enrollment|
      next true if user.instructor_of?(enrollment.course)
      if context[:params][:enrollment].present?
        next false if Role.higher_security?(Role.find(context[:params][:enrollment][:role_id]), enrollment.role)
      end
      (enrollment.user == user)
    end
  end
end
