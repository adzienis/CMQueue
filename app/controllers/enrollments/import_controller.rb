class Enrollments::ImportController < ApplicationController
  def index
  end

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

  def create
    file = params[:file].read
    json = JSON.parse(file)

    new_imports = 0
    updated_imports = 0

    json.each do |student|
      email = student["email"]
      name = student["name"]

      enrollment = student["enrollments"][0]
      type = enrollment["type"]

      split_name = name.split(" ")
      given_name = split_name[0]
      family_name = split_name[-1]

      user = User.find_by(email: email)

      next if user == current_user

      if user.nil?
        user = User.create(given_name: given_name, family_name: family_name, email: email)
      else
        user.update(given_name: given_name, family_name: family_name)
      end

      enrollment = user.enrollment_in_course(@course)

      if enrollment.present?
        unless role_equal?(user.enrollment_in_course(@course).role.name, type)
          updated_imports += 1
          enrollment.discard
          case type
          when "StudentEnrollment"
            user.add_role :student, @course
          when "TaEnrollment"
            user.add_role :ta, @course
          when "TeacherEnrollment"
            user.add_role :instructor, @course
          end
        end
      else
        new_imports += 1
        case type
        when "StudentEnrollment"
          user.add_role :student, @course
        when "TaEnrollment"
          user.add_role :ta, @course
        when "TeacherEnrollment"
          user.add_role :instructor, @course
        else
          new_imports -= 1
        end
      end
    end

    flash[:success] = "Successfully imported #{json.count} entries.
                       Created #{new_imports} new entries, and updated #{updated_imports} entries."
  rescue JSON::ParserError => e
    flash[:error] = "Failed to import file: failed to parse file (make sure to upload a valid json file)."
  rescue Exception => e
    flash[:error] = "Failed to import file."
  ensure
    redirect_to search_course_enrollments_path(@course)
  end
end
