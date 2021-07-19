# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.present?

      if user.has_role? :admin
        can :manage, :all
        can :read, :dashboard
        can :access, :rails_admin
      end
      #can :manage, Message, question_state: { question: { user: { id: user.id } } }

      can :queue, Course

      can [:active_tas, :open_status, :read, :search], Course
      can :read, User
      can :semester, Course

      can :enroll_user, User do |u|
        user.id == u.id
      end

      # cannot :download, Tag

      can :manage, Notification, Notification.where(recipient_type: "User", recipient_id: user.id) do |notification|
        notification.recipient_type == "User" && notification.recipient_id == user.id
      end

      can :manage, Setting, Setting.where(resource_id: user.id, resource_type: "User")
                                   .or(Setting.where(resource_id: Course.find_roles([:ta, :instructor], user).pluck(:resource_id), resource_type: "Course")) do |setting|
        (user.id == setting.resource_id && setting.resource_type == "User") or
          (setting.resource_type == "Course" && (user.has_any_role?({name: :instructor, resource: enrollment.course })))
      end

      #can :read, Enrollment, Enrollment.joins(:role)
      #                                    .where("roles.resource_id": Course
      #                                                                    .where("courses.id": Course.find_roles([:ta], user)
      #                                                                                               .pluck(:resource_id))
      #                                                                    .pluck(:id))

      can :manage, Enrollment, Enrollment.joins(:role)
                                       .where("roles.resource_id": Course
                                                                     .where("courses.id": Course.find_roles([:instructor], user)
                                                                                                .pluck(:resource_id))
                                                                     .pluck(:id))
                                       .or(Enrollment.where("enrollments.user_id": user.id)) do |enrollment|
        enrollment.user_id == user.id || (user.has_any_role?({name: :instructor, resource: enrollment.course }))
      end

      #can :manage, Message, Message.joins(:question_state).joins(question_state: :question)
      #                                .where("questions.course_id": Course
      #                                                              .where("courses.id": Course.find_roles([:instructor], user)
      #                                                                                         .pluck(:resource_id))
      #                                                              .pluck(:id))
      #                                .or(Message.where(user_id: user.id))



      cannot :read, Course, [:instructor_code] do |course|
        !user.has_role?(:instructor, course)
      end

      cannot :read, Course, [:ta_code] do |course|
        !user.has_role?(:instructor, course) && !user.has_role?(:ta, course)
      end


      can [:course_info, :roster, :open,
           :update, :top_question, :answer, :answer_page], Course, Course.where(id: Course.find_roles([:ta, :instructor], user).pluck(:resource_id)) do |course|
        user.has_any_role?({ name: :ta, resource: course}, {name: :instructor, resource: course})
      end

      can :manage, QuestionState, QuestionState.joins(:question)
                                               .where("questions.course_id": Course
                                                        .where("courses.id": Course.find_roles([:ta, :instructor], user)
                                                                         .pluck(:resource_id))
                                                        .pluck(:id))
                                               .or(QuestionState.where("question_states.enrollment_id": user.enrollments.pluck(:id)))
                                               .or(QuestionState.where("questions.enrollment_id": user.enrollments.pluck(:id))) do |state|

        user.has_any_role?({ name: :ta, resource: state.question.course}, {name: :instructor, resource: state.question.course}) || state.question.user_id == user.id
      end

      #can :manage, Message, Message.all do |message|
      #  user.has_any_role?({ name: :ta, resource: message.question_state.question.course}, {name: :instructor, resource: message.question_state.question.course})
      #end

      can :read, Tag
      can :create, Tag if (user.roles.where(name: 'ta').or(user.roles.where(name: 'instructor'))).count.positive?


      can :read, Role if (user.roles.where(name: 'ta').or(user.roles.where(name: 'instructor'))).count.positive?

      can :manage, Tag, Tag
        .where(course_id: Course
                                              .where(id: Course.find_roles([:ta, :instructor], user)
                                                               .pluck(:resource_id))
                                              .pluck(:id)) do |tag|
        user.has_any_role?({ name: :ta, resource: tag.course}, {name: :instructor, resource: tag.course})
      end

      can :manage, Question, Question.joins(:enrollment)
        .where(course_id: Course.where(id: Course.find_roles([:ta, :instructor], user)
                                                                    .pluck(:resource_id))
                                                   .pluck(:id)).or(Question.where("enrollments.user_id": user.id)) do |question|
        user.has_any_role?({ name: :ta, resource: question.course}, {name: :instructor, resource: question.course}) || question.user&.id == user.id || question.new_record?
      end

    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
