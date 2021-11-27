class CourseChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user unless params[:room]

    if params[:room]
      course = Course.find(params[:room])
      role   = current_user.enrollment_in_course(course).role.name

      stream_for course if params[:type] == "general"
      stream_from "course:#{params[:room]}:#{role}" if params[:type] == "role"
      stream_from "course:#{params[:room]}:staff" if params[:type] == "role" && Role.staff_role_names.include?(role)
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
