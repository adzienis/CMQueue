class QuestionStateAbility < BaseAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?

    @staff_roles = Course.find_staff_roles(user).pluck(:resource_id)

    can :manage, QuestionState, QuestionState.joins(:question)
      .where("questions.course_id": @staff_roles)
      .or(QuestionState.where("question_states.enrollment_id": user.enrollments.pluck(:id)))
      .or(QuestionState.where("questions.enrollment_id": user.enrollments.pluck(:id))) do |state|
      user.staff_of?(state.course) || state.question.user == user
    end
  end
end
