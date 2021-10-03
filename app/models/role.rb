# frozen_string_literal: true

class Role < ApplicationRecord

  include FindableByCourseRoles

  has_many :enrollments, dependent: :delete_all

  scope :with_courses, ->(*courses) { where(resource: courses, resource_type: "Course") }
  scope :with_resources, ->(*resources) { where(resource: resources) }

  belongs_to :resource,
             polymorphic: true,
             optional: true

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true
  validates :name, presence: true

  scope :privileged_roles, ->{where(name: ["lead_ta", "instructor"])}
  scope :staff_roles, ->{where(name: ["ta", "lead_ta", "instructor"])}
  scope :undiscarded, ->{joins(:enrollments).merge(Enrollment.undiscarded)}

  def course
    Course.find(resource_id) if resource_type == "Course"
  end

  def self.role_security_value(role_name)
    case role_name
    when "instructor"
      0
    when "head_ta"
      1
    when "ta"
      2
    when "student"
      3
    end
  end

  def self.higher_security?(role_tested, role_compared_to)
    role_security_value(role_tested) > role_security_value(role_compared_to)
  end

  scopify
end
