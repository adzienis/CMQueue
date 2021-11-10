class QuestionAbility
  include CanCan::Ability

  def initialize(user, context)
    return unless user.present?
    @staff_roles = Course.find_staff_roles(user).pluck(:resource_id)
    @privileged_roles = Course.find_privileged_staff_roles(user).pluck(:resource_id)
    can :search, Question if @staff_roles.any?
    can :count, Question if @staff_roles.any?

    can :create_handle, Question do |question|
      user.staff_of?(question.course)
    end

    can :update_state, Question, Question.joins(:course, :enrollment).where(courses: @staff_roles)
                                 .or(Question.where("enrollments.user_id": user.id)) do |question|
      user.staff_of?(question.course) || question.user == user
    end

    # return if context[:path_parameters][:course_id].present? && !@staff_roles.include?(context[:params][:course_id].to_i)
    can :read, Question, Question.joins(:course, :enrollment).where(courses: @staff_roles)
                                   .or(Question.where("enrollments.user_id": user.id)) do |question|
      user.staff_of?(question.course) || question.user == user
    end

    can [:create, :update, :destroy, :position], Question, Question.joins(:course, :enrollment)
                                   .where(courses: @privileged_roles).or(Question.where("enrollments.user_id": user.id)) do |question|
      user.staff_of?(question.course) || question.user == user
    end
  end
end

