class SyncedTurboChannel < ApplicationCable::Channel
  extend Turbo::Streams::StreamName
  extend Turbo::Streams::Broadcasts
  include Turbo::Streams::StreamName::ClassMethods

  def handle_course_updates(course)
  end

  def handle_user_updates(user)
  end

  def unsubscribed
  end

  def handle_course_user_updates(course, user)
    active_question = user.active_question(course: course)

    if active_question.present?
      comp = Forms::Questions::QuestionCreatorComponent.new(course: course,
        question_form: Forms::Question.new(question: active_question),
        current_user: user)
      SyncedTurboChannel.broadcast_update_to user,
        target: "question-form",
        html: ApplicationController.render(comp,
          layout: false)
    end

    SyncedTurboChannel.broadcast_replace_to course, user,
      target: "questions-count",
      html: ApplicationController
        .render(Courses::QuestionsCountComponent.new(course: course),
          layout: false)
    SyncedTurboChannel.broadcast_replace_to(course, user,
      target: "queue-open-status",
      html: ApplicationController
              .render(Courses::QueueOpenStatusComponent.new(course: course),
                layout: false))

    if user.staff_of?(course)
      Enrollments::UpdateFeedJob.perform_later(enrollment: user.enrollment_in_course(course))
    end

    CourseChannel.broadcast_to user, {
      type: "event",
      event: "invalidate:question-feed"
    }
  end

  #
  # @param [String] stream_name
  #
  def handle_reconnect_updates(stream_name)
    gids = stream_name.split(":")
    resources = gids.map { |gid| GlobalID::Locator.locate gid }.compact

    if resources.count == 1
      resource = resources.first

      if resource.instance_of?(User)
      elsif resource.instance_of?(Course)
        handle_course_updates(resource)
      end
    elsif resources.count == 2
      one, two = resources

      if one.instance_of?(Course) && two.instance_of?(User)
        handle_course_user_updates(one, two)
      end
    end
  end

  def request
    connection.request_var
  end

  def set_variant
    agent = request.user_agent
    return request.variant = :tablet if /(tablet|ipad)|(android(?!.*mobile))/i.match?(agent)
    return request.variant = :mobile if /Mobile/.match?(agent)
    request.variant = :desktop
  end

  def subscribed
    # set_variant
    if (stream_name = verified_stream_name_from_params).present?
      stream_from stream_name
      handle_reconnect_updates(stream_name)
    else
      reject
    end
  end
end
