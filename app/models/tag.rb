# frozen_string_literal: true

class Tag < ApplicationRecord
  include Discard::Model
  include RansackableConcern

  validates :name, uniqueness: true, presence: true

  scope :with_course, ->(course) { where(course_id: course.id) }

  belongs_to :course
  has_many :question_tags
  has_many :questions, dependent: :destroy, through: :question_tags
end
