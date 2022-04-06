class CourseChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user unless params[:room]

    if params[:room]
      ActiveRecord::Base.transaction do
        Postgres::Locks.pg_advisory_xact_lock(current_user.enrollment_in_course(course).id)
        Cmq::ActionCable::Connections.add_enrollment_to_room(room_name, current_user.enrollment_in_course(course).id)
        SpecialLogger.info "subscribed: #{room_name}; #{current_user.email}; room: #{room_name}; entries: #{Kredis.hash(room_name, typed: :integer).entries}; time: #{params[:time]}"
        stream_for room
      end
    end
  end

  def room_name
    if room.is_a?(Course)
      "course:#{room.id}"
    else
      room
    end
  end

  def course
    @course ||= Course.find(params[:room])
  end

  def role
    current_user.enrollment_in_course(course).role.name
  end

  def room
    return course if params[:type] == "general"
    return "course:#{params[:room]}:staff" if params[:type] == "role" && Role.staff_role_names.include?(role)
    return "course:#{params[:room]}:#{role}" if params[:type] == "role"
  end

  def unsubscribed

    ActiveRecord::Base.transaction do
      Postgres::Locks.pg_advisory_xact_lock(current_user.enrollment_in_course(course).id)
      SpecialLogger.info "unsubscribed: #{room_name}; #{current_user.email}: entries: #{Kredis.hash(room_name, typed: :integer).entries}; time: #{params[:time]}"
      if params[:room].present?
        Cmq::ActionCable::Connections.remove_enrollment_from_room(room_name, current_user.enrollment_in_course(course).id)
      end
    end
  end
end
