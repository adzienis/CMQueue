class QuestionAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?
    @staff_roles = Course.find_staff_roles(user).pluck(:resource_id)

    can :create_handle, Question do |question|
      user.staff_of?(question.course)
    end

    can :manage, Question, Question.joins(:course, :enrollment)
                                   .where(courses: @staff_roles).or(Question.where("enrollments.user_id": user.id)) do |question|
      user.staff_of?(question.course) || question.user == user
    end
  end
end

