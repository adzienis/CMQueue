# frozen_string_literal: true

class Role < ApplicationRecord

  has_many :enrollments, dependent: :delete_all

  scope :with_course, ->(course) { where(resource_id: course.id) }

  belongs_to :resource,
             polymorphic: true,
             optional: true

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  scope :undiscarded, ->{joins(:enrollments).merge(Enrollment.undiscarded)}

  scopify

end
