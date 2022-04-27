class CourseAbility < Courses::BaseAbility
  include CanCan::Ability

  def initialize(user, context)
    super

    can :active_tas, course

    return unless enrollment.staff?

    can [:read_open, :update_open, :answer], course
    can :queue, course
    can :semester, course
    can :read, :staff_log

    return unless enrollment.privileged?

    can [
          :course_info, :roster, :open, :update,
          :top_question, :answer_page,
          :read, :queue_show, :index_database], course
  end
end
