class ImportEnrollmentsJob < ApplicationJob
  queue_as :default

  def role_equal?(current_role, new_role)
    case new_role
    when "StudentEnrollment"
      current_role == "student"
    when "TaEnrollment"
      current_role == "ta"
    when "TeacherEnrollment"
      current_role == "instructor"
    end
  end

  def perform(json:, course:, current_user: nil)
    new_imports = 0
    updated_imports = 0
    message = ""
    failure = false

    pres_sections = course.courses_sections.to_a
    pres_sections_h = pres_sections.map { |v| [v[:name], v[:id]] }.to_h || {}

    json.each do |student|
      email = student["email"]
      name = student["name"]

      enrollment = student["enrollments"][0]
      student_sections = student["enrollments"].map { |e| e["section"] }
      type = enrollment["type"]

      split_name = name.split(" ")
      given_name = split_name[0]
      family_name = split_name[-1]

      user = User.find_by(email: email)

      unless email.present?
        next
      end
      next if user == current_user && current_user.present?

      if user.nil?
        user = User.create!(given_name: given_name, family_name: family_name, email: email)
      else
        user.update(given_name: given_name, family_name: family_name)
      end

      enrollment = user.enrollment_in_course(course)

      #student_sections.each do |sec|
      #  if sec.present? && pres_sections_h[sec["name"]].nil?
      #    created = course.courses_sections.create(name: sec["name"])
      #    pres_sections_h[created.name] = created.id
      #  end
      #end

      if enrollment.present?
        unless role_equal?(user.enrollment_in_course(course).role.name, type)
          updated_imports += 1
          enrollment.discard
          case type
          when "StudentEnrollment"
            user.enrollments.create(role: course.student_role)
          when "TaEnrollment"
            user.enrollments.create(role: course.ta_role)
          when "TeacherEnrollment"
            user.enrollments.create(role: course.instructor_role)
          end
        end
      else
        new_imports += 1
        case type
        when "StudentEnrollment"
          user.enrollments.create(role: course.student_role)
        when "TaEnrollment"
          user.enrollments.create(role: course.ta_role)
        when "TeacherEnrollment"
          user.enrollments.create(role: course.instructor_role)
        else
          new_imports -= 1
        end
      end

    rescue JSON::ParserError => e
      message = "Failed to import file: failed to parse file (make sure to upload a valid json file)."
      failure = true
      break
    rescue Exception => e
      message = "Failed to import file."
      failure = true
      break
    end

    unless failure
      message = <<~MSG.chomp
        Successfully imported enrollments. Created #{new_imports} new entries, and updated #{updated_imports} entries.
      MSG
    end

    SiteNotification.with(message: message, site: true).deliver_later(current_user)
  end
end
