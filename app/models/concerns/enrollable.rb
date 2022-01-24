module Enrollable
  extend ActiveSupport::Concern

  def enrolled_in_course?(course)
    enrolled_in_courses?(course)
  end

  def enrolled_in_courses?(*courses)
    active_enrollments.merge(Enrollment.with_courses(courses)).exists?
  end

  def staff_of?(obj)
    ta_of?(obj) || lead_ta_of?(obj) || instructor_of?(obj)
  end

  def privileged_staff_of?(obj)
    lead_ta_of?(obj) || instructor_of?(obj)
  end

  def enrollment_in_course(course, active: true)
    filtered_enrollments = if active.nil?
      enrollments
    elsif active
      enrollments.active
    else
      enrollments.inactive
    end

    if course.instance_of? Course
      filtered_enrollments.joins(:role).where("roles.resource": course).order(created_at: :desc).first
    elsif course.instance_of? Integer
      filtered_enrollments.joins(:role).where("roles.resource_id": course, "roles.resource_type": "Course").order(created_at: :desc).first
    end
  end

  class_methods do
    def with_staff_of(course)
      joins(:enrollments, enrollments: :role).merge(Enrollment.undiscarded)
        .where("roles.resource_type": "Course", "roles.resource_id": course.id,
          "roles.name": "ta")
        .or(where("roles.resource_type": "Course", "roles.resource_id": course.id,
          "roles.name": "instructor"))
    end
  end

  [:ta, :lead_ta, :instructor, :student].each do |role|
    define_method("#{role}_of?") do |obj|
      if obj.instance_of? Course
        has_role?(role.to_sym, obj)
      elsif obj.instance_of? Integer
        course = Course.find(obj)
        has_role?(role.to_sym, course)
      else
        false
      end
    end
  end
end
