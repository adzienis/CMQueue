# frozen_string_literal: true

class Tag < ApplicationRecord
  scope :with_course, ->(course) { where(course_id: course.id) }

  belongs_to :course
  has_and_belongs_to_many :questions
end
