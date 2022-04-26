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

  def status_file
    return @status_file if defined?(@status_file)
    @status_file = Tempfile.new("import_log")
  end

  def perform(json:, course:, current_user: nil, import_record: nil)
    PaperTrail.request.whodunnit = current_user&.id

    @json = json
    @course = course
    @current_user = current_user
    @import_record = import_record

    new_imports = 0
    updated_imports = 0
    message = ""
    failure = false

    pres_sections = course.courses_sections.to_a
    pres_sections_h = pres_sections.map { |v| [v[:name], v[:id]] }.to_h || {}

    status_file.write("name,role/error\n")

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
        status_file.write("#{student["name"]},DID NOT IMPORT (MISSING EMAIL)\n")
        next
      end

      if user == current_user && current_user.present?
        status_file.write("#{user.given_name}, DID NOT IMPORT/UPDATE (LOGGED IN USER)\n")
        next
      end

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
        if role_equal?(user.enrollment_in_course(course).role.name, type)
          unless user.enrollment_in_course(course).semester == Enrollment.default_semester
            enrollment.archive!

            case type
            when "StudentEnrollment"
              user.enrollments.create!(role: course.student_role)
            when "TaEnrollment"
              user.enrollments.create!(role: course.ta_role)
            when "TeacherEnrollment"
              user.enrollments.create!(role: course.instructor_role)
            end
          end
        else
          updated_imports += 1
          enrollment.archive!
          case type
          when "StudentEnrollment"
            user.enrollments.create!(role: course.student_role)
          when "TaEnrollment"
            user.enrollments.create!(role: course.ta_role)
          when "TeacherEnrollment"
            user.enrollments.create!(role: course.instructor_role)
          end
        end
      else
        new_imports += 1
        case type
        when "StudentEnrollment"
          user.enrollments.create!(role: course.student_role)
        when "TaEnrollment"
          user.enrollments.create!(role: course.ta_role)
        when "TeacherEnrollment"
          user.enrollments.create!(role: course.instructor_role)
        else
          new_imports -= 1
        end
      end

      if user.enrollment_in_course(course).present?
        status_file.write("#{user.full_name},#{user.enrollment_in_course(course)&.role&.name}\n")
      else
        status_file.write("#{user.full_name},DID NOT IMPORT\n")
      end

    rescue JSON::ParserError => e
      message = "Failed to import file: failed to parse file (make sure to upload a valid json file)."
      failure = true
      break
    rescue Exception => e
      SpecialLogger.info e
      message = "Failed to import file."
      failure = true
      break
    end

    unless failure
      message = <<~MSG.chomp
        Successfully imported enrollments. Created #{new_imports} new entries, and updated #{updated_imports} entries.
      MSG
      status_file.write("\n-------------------------\n")
      status_file.write("SUMMARY\n")
      status_file.write("-------------------------\n")
      status_file.write("#{message}\n")
    end

    status_file.rewind
    import_record.status_log.attach(io: status_file, filename: "import_log.txt", content_type: "text/plain")

    SiteNotification.with(message: message, site: true).deliver_later(current_user)
  end
end
