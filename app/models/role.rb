# frozen_string_literal: true

class Role < ApplicationRecord

  has_many :enrollments, dependent: :delete_all

  scope :with_course, ->(course_id) { where(resource_id: course_id, resource_type: "Course") }

  belongs_to :resource,
             polymorphic: true,
             optional: true

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true
  validates :name, presence: true

  scope :undiscarded, ->{joins(:enrollments).merge(Enrollment.undiscarded)}

  def course
    Course.find(resource_id) if resource_type == "Course"
  end

  def self.role_security_value(role_name)
    case role_name
    when "instructor"
      0
    when "ta"
      1
    when "student"
      2
    end
  end

  def self.higher_security?(role_tested, role_compared_to)
    role_security_value(role_tested) > role_security_value(role_compared_to)
  end

  scopify
end
