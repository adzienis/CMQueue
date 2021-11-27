# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id            :bigint           not null, primary key
#  name          :string
#  resource_type :string
#  resource_id   :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Role < ApplicationRecord

  include FindableByCourseRoles

  has_many :enrollments, dependent: :delete_all

  belongs_to :course, -> { where(roles: {resource_type: 'Course'}) }, foreign_key: 'resource_id', optional: true

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
      3
    when "lead_ta"
      2
    when "ta"
      1
    when "student"
      0
    end
  end

  def self.privileged_role_names
    ["instructor", "lead_ta"]
  end

  def self.staff_role_names
    ["ta", "instructor", "lead_ta"]
  end

  def self.student_role_names
    ["student"]
  end

  def self.higher_security?(role_tested, role_compared_to)
    role_security_value(role_tested.name) > role_security_value(role_compared_to.name)
  end

  scopify
end
