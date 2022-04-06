class SyncedTurboChannel < ApplicationCable::Channel
  extend Turbo::Streams::StreamName
  extend Turbo::Streams::Broadcasts
  include Turbo::Streams::StreamName::ClassMethods

  def unsubscribed
  end

  def handle_course_user_updates(course, user)
    active_question = user.active_question(course: course)

    if active_question.present?
      SyncedTurboChannel.broadcast_update_to(
        course, user,
        target: "question-form",
        html: ApplicationController.render(Forms::Questions::QuestionCreatorComponent.new(
          course: course,
          question_form: Forms::Question.new(question: active_question),
          current_user: user
        ), layout: false)
      )
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


    SyncedTurboChannel
      .broadcast_replace_later_to course, user,
                                  target: "active-staff",
                                  html: ApplicationController
                                          .render(Courses::ActiveStaffComponent.new(course: course),
                                                  layout: false)
  end

  #
  # @param [String] stream_name
  #
  def handle_reconnect_updates(stream_name)
    gids = stream_name.split(":")
    resources = gids.map { |gid| GlobalID::Locator.locate gid }.compact

    if resources.length == 2 && resources[0].is_a?(Course) && resources[1].is_a?(User)

      course, user = resources
      handle_course_user_updates(course, user)
    end
  end

  def reconnected?(stream_name)
    last_connected_at = Kredis.datetime(stream_name).value
    return false if last_connected_at.nil?
    last_connected_at < 5.minutes.ago
  end

  def subscribed
    super
    if (stream_name = verified_stream_name_from_params).present?
      stream_from stream_name
      handle_reconnect_updates(stream_name)
    else
      reject
    end
  end
end
