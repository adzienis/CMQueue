class CourseChannel < ApplicationCable::Channel
  def subscribed
    if params[:room]
      if params[:type] == "general"
        SyncStudentTitle.call(enrollment: current_enrollment) if current_enrollment.student?
      end
      return stream_for(room)
    end

    stream_for current_user
  end

  def room_name
    @room_name ||= if room.is_a?(Course)
      "course:#{room.id}"
    else
      room
    end
  end

  def course
    @course ||= Course.find(params[:room])
  end

  def role
    @role ||= current_user.enrollment_in_course(course).role.name
  end

  def room
    return @room if defined?(@room)
    return @room = course if params[:type] == "general"
    return @room = "course:#{params[:room]}:staff" if params[:type] == "role" && Role.staff_role_names.include?(role)
    @room = "course:#{params[:room]}:#{role}" if params[:type] == "role"
    @room
  end

  def current_enrollment
    @current_enrollment ||= current_user.enrollment_in_course(course)
  end
end
