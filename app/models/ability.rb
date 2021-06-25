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

      can [:active_tas, :open_status, :read, :search], Course
      can :read, User

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
                                               .or(QuestionState.where("question_states.user_id": user.id))
                                               .or(QuestionState.where("questions.user_id": user.id)) do |state|

        user.has_any_role?({ name: :ta, resource: state.question.course}, {name: :instructor, resource: state.question.course}) || state.question.user_id == user.id
      end

      can :manage, Message, Message.all do |message|
        user.has_any_role?({ name: :ta, resource: message.question_state.question.course}, {name: :instructor, resource: message.question_state.question.course})
      end

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

      can :manage, Question, Question
        .where(course_id: Course
                                                   .where(id: Course.find_roles([:ta, :instructor], user)
                                                                    .pluck(:resource_id))
                                                   .pluck(:id)).or(Question.where(user_id: user.id)) do |question|
        user.has_any_role?({ name: :ta, resource: question.course}, {name: :instructor, resource: question.course}) || question.user_id == user.id
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
