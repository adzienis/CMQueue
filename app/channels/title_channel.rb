class TitleChannel < ApplicationCable::Channel
  include HasConnections

  [:students, :tas, :instructors, :staff].each do |role_type|
    define_singleton_method "broadcast_to_#{role_type}" do |course:, message:, coder: ActiveSupport::JSON|
      broadcast_to "#{course.id}:#{role_type.to_s.singularize}", message
    end
  end

  def subscribed
    stream_for current_user unless params[:room]

    if params[:room]
      course = Course.find(params[:room])
      role = current_user.enrollment_in_course(course).role.name

      stream_for course if params[:type] == "general"
      stream_from "title:#{params[:room]}:#{role}" if params[:type] == "role"
      stream_from "title:#{params[:room]}:staff" if params[:type] == "role" && Role.staff_role_names.include?(role)
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
