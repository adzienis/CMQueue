# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user, context)
    if user.present?

      if user.has_role? :admin
        can :manage, :all
        can :read, :dashboard
        can :access, :rails_admin
      end
      #can :manage, Message, question_state: { question: { user: { id: user.id } } }

      @instructor_roles = Course.find_roles([:instructor], user).pluck(:resource_id)
      @privileged_roles = Course.find_privileged_staff_roles(user).pluck(:resource_id)
      @staff_roles = Course.find_staff_roles(user).pluck(:resource_id)

      can :manage, Certificate, Certificate
                                  .where(course_id: @instructor_roles
                                  )

      can :queue, Course

      can [:active_tas, :open, :read, :search], Course
      can :read, User
      can :semester, Course

      can :enroll_user, User do |u|
        user.id == u.id
      end

      can :manage, User, User.where(id: user.id) do |tested_user|
        tested_user == user
      end

      # cannot :download, Tag,

      can :manage, Notification, Notification.where(recipient_type: "User", recipient_id: user.id) do |notification|
        notification.recipient_type == "User" && notification.recipient_id == user.id
      end

      can :manage, Setting, Setting.where(resource_id: user.id, resource_type: "User")
                                   .or(Setting.where(resource_id: @instructor_roles, resource_type: "Course")) do |setting|
        case setting.resource_type
        when "User"
          user.id == setting.resource_id
        when "Course"
          user.instructor_of?(setting.resource_id)
        end
      end

      #can :read, Enrollment, Enrollment.joins(:role)
      #                                 .where("roles.resource_id": Course
      #                                                               .where("courses.id": Course.find_roles([:ta], user)
      #                                                                                          .pluck(:resource_id))
      #                                                               .pluck(:id)) do |enrollment|
      #  false
      #end

      can :new, Enrollment do |enrollment |
        enrollment.new_record?
      end

      can [:create, :edit], Enrollment do |enrollment|
        (enrollment.user == user && enrollment.role.name == "student") || (user.instructor_of?(enrollment.course))
      end

      can [:read, :destroy], Enrollment, Enrollment.joins(:role).where(user: user).or(Enrollment.where("roles.resource_id": @staff_roles)) do |enrollment|
        (enrollment.user == user)
      end

      can [:update], Enrollment, Enrollment.joins(:role).where(user: user).or(Enrollment.where("roles.resource_id": @staff_roles)) do |enrollment|
        next true if user.instructor_of?(enrollment.course)
        if context[:params][:enrollment].present?
          next false if Role.higher_security?(Role.find(context[:params][:enrollment][:role_id]), enrollment.role)
        end
        (enrollment.user == user)
      end

      #can :manage, Message, Message.joins(:question_state).joins(question_state: :question)
      #                                .where("questions.course_id": Course
      #                         enrollment                                     .where("courses.id": Course.find_roles([:instructor], user)
      #                                                                                         .pluck(:resource_id))
      #                                                              .pluck(:id))
      #                                .or(Message.where(user_id: user.id))

      cannot :read, Course, [:instructor_code] do |course|
        !user.instructor_of?(course.id)
      end

      cannot :read, Course, [:ta_code] do |course|
        !user.staff_of?(course)
      end

      ########################################################################
      # cannot create or update an enrollment if the user isn't an instructor

      ###############################################

      can [:course_info, :roster, :open,
           :update, :top_question, :answer, :answer_page], Course, Course.where(id: @staff_roles) do |course|
        user.staff_of?(course)
      end

      can :manage, Course, Course.where(id: @privileged_roles) do |course|
        user.instructor_of?(course)
      end

      can :queue_show, Course, Course.where(id: @staff_roles) do |course|
        user.staff_of?(course)
      end

      can :answer, Course, Course.where(id: @staff_roles) do |course|
        user.staff_of?(course)
      end

      can :manage, QuestionState, QuestionState.joins(:question)
                                               .where("questions.course_id": @staff_roles)
                                               .or(QuestionState.where("question_states.enrollment_id": user.enrollments.pluck(:id)))
                                               .or(QuestionState.where("questions.enrollment_id": user.enrollments.pluck(:id))) do |state|
        user.staff_of?(state.course) || state.question.user == user
      end

      #can :manage, Message, Message.all do |message|
      #  user.has_any_role?({ name: :ta, resource: message.question_state.question.course}, {name: :instructor, resource: message.question_state.question.course})
      #end

      can :read, Tag
      can :create, Tag if (user.roles.where(name: ['ta', 'instructor', 'lead_ta'])).exists?

      can :manage, Role, Role.where(resource_id: @privileged_roles) do |role|
        (role.new_record? && user.has_role?(:instructor, :any)) || user.instructor_of?(role.course)
      end
      can :new, TagGroup do |tag_group|
        tag_group.new_record?
      end

      can :manage, TagGroup, TagGroup.where(course_id: @staff_roles) do |tag_group|
        user.privileged_staff_of?(tag_group.course)
      end

      can :manage, Analytics::Dashboard, Analytics::Dashboard.where(course_id: @staff_roles) do |dashboard|
        dashboard.new_record? || user.privileged_staff_of?(dashboard.course)
      end

      can :manage, Tag, Tag.where(course_id: @privileged_roles) do |tag|
        user.privileged_staff_of?(tag.course)
      end

      can :create_handle, Question do |question|
        user.staff_of?(question.course)
      end

      can :index_database, Course do |course|
        user.privileged_staff_of?(course)
      end

      can :manage, Question, Question.joins(:course, :enrollment)
                                     .where(courses: @staff_roles).or(Question.where("enrollments.user_id": user.id)) do |question|
        user.staff_of?(question.course) || question.user == user
      end

    end
  end
end
