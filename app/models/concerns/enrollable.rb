module Enrollable
  extend ActiveSupport::Concern

  included do
    has_many :active_enrollments, -> { undiscarded }, dependent: :destroy, class_name: "Enrollment"
    has_many :enrollments, dependent: :destroy
  end

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

  def enrollment_in_course(course)
    if course.instance_of? Course
      enrollments.undiscarded.joins(:role).where("roles.resource": course).order(created_at: :desc).first
    elsif course.instance_of? Integer
      enrollments.undiscarded.joins(:role).where("roles.resource_id": course, "roles.resource_type": "Course").order(created_at: :desc).first
    else
      nil
    end
  end

  [:ta, :lead_ta, :instructor, :student].each do |role|
    self.define_method("#{role}_of?") do |obj|
      if obj.instance_of? Course
        has_any_role?({ name: role.to_sym, resource: obj })
      elsif obj.instance_of? Integer
        course = Course.find(obj)
        has_any_role?({ name: role.to_sym, resource: course })
      else
        false
      end
    end
  end

end